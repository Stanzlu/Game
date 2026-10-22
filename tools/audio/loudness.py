"""Loudness helpers shared by the sound generators and check_levels.py (BS.1770 K-weighting,
any sample rate), so a generator and the check that guards it measure with one ruler.

- lufs(): integrated loudness of a one-shot (gated like BS.1770; sounds shorter than one
  400 ms block count their whole length), or of a loop (`periodic`: ungated, the filter
  wraps around so the seam stays out of the measurement).
- normalize_lufs(): gain to a target loudness under a soft ceiling, iterated because the
  limiter takes some of it back.
"""
import numpy as np

CEILING_DB = -1.0
CEILING = 10 ** (CEILING_DB / 20)


def _biquad_gain(f, b, a, rate):
    z = np.exp(-2j * np.pi * f / rate)
    return np.abs((b[0] + b[1] * z + b[2] * z * z) / (a[0] + a[1] * z + a[2] * z * z))


def k_weighting(f, rate):
    """Magnitude of the K filter: high shelf +4 dB around 1.7 kHz, highpass at 38 Hz."""
    g = 10 ** (4.0 / 40)
    w = 2 * np.pi * 1681.97 / rate
    c, s = np.cos(w), np.sqrt(g) * np.sin(w) / 0.7072
    shelf = _biquad_gain(
        f,
        [g * ((g + 1) + (g - 1) * c + s), -2 * g * ((g - 1) + (g + 1) * c), g * ((g + 1) + (g - 1) * c - s)],
        [(g + 1) - (g - 1) * c + s, 2 * ((g - 1) - (g + 1) * c), (g + 1) - (g - 1) * c - s],
        rate,
    )
    w = 2 * np.pi * 38.135 / rate
    c, alpha = np.cos(w), np.sin(w) / (2 * 0.5003)
    high = _biquad_gain(f, [(1 + c) / 2, -(1 + c), (1 + c) / 2], [1 + alpha, -2 * c, 1 - alpha], rate)
    return shelf * high


def k_filtered(x, rate, periodic=False):
    """x through the K filter. One-shots are padded so the filter does not wrap the tail
    around to the head."""
    n = len(x)
    size = n if periodic else 2 * n
    spec = np.fft.rfft(x, size)
    f = np.fft.rfftfreq(size, 1.0 / rate)
    return np.fft.irfft(spec * k_weighting(f, rate), size)[:n]


def lufs(x, rate, periodic=False):
    z = k_filtered(np.asarray(x, dtype=float), rate, periodic) ** 2
    if periodic:
        return -0.691 + 10 * np.log10(np.mean(z) + 1e-20)
    block, hop = int(0.4 * rate), int(0.1 * rate)
    if len(z) < block:
        return -0.691 + 10 * np.log10(np.mean(z) + 1e-20)
    cum = np.concatenate([[0.0], np.cumsum(z)])
    starts = np.arange(0, len(z) - block + 1, hop)
    ms = (cum[starts + block] - cum[starts]) / block
    lk = -0.691 + 10 * np.log10(ms + 1e-20)
    keep = lk > -70
    if not keep.any():
        return -120.0
    relative = -0.691 + 10 * np.log10(np.mean(ms[keep])) - 10
    keep &= lk > relative
    return -0.691 + 10 * np.log10(np.mean(ms[keep]))


def peak_db(x):
    return 20 * np.log10(np.max(np.abs(x)) + 1e-12)


def soft_limit(x, ceiling=CEILING, knee=0.5):
    """Leaves samples below knee * ceiling alone and bends louder ones smoothly towards the
    ceiling. Works sample by sample, so loops stay seamless."""
    start = knee * ceiling
    room = ceiling - start
    over = np.abs(x) > start
    out = x.copy()
    out[over] = np.sign(x[over]) * (start + room * np.tanh((np.abs(x[over]) - start) / room))
    return out


def normalize_lufs(x, rate, target, periodic=False, max_squash_db=4.0):
    """Scales x to `target` LUFS under the soft ceiling. A sound with sharp peaks cannot
    reach every target: the gain stops once the limiter would take more than `max_squash_db`
    off its peaks, and the sound ends up quieter than asked (check_levels.py reads the
    result, not the wish)."""
    x = np.asarray(x, dtype=float)
    if np.max(np.abs(x)) < 1e-9:
        return x
    gain = 10 ** ((target - lufs(x, rate, periodic)) / 20)
    for _ in range(4):
        limited = soft_limit(x * gain)
        error = target - lufs(limited, rate, periodic)
        if abs(error) < 0.05:
            break
        gain *= 10 ** (error / 20)
    # cap the drive into the limiter
    cap = 10 ** (max_squash_db / 20) * CEILING / (np.max(np.abs(x)) + 1e-12)
    gain = min(gain, cap)
    return soft_limit(x * gain)
