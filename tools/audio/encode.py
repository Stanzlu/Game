"""Ogg Vorbis encoding for the generators (ADR-057): a WAV in, an OGG out, through ffmpeg.

ffmpeg is a development tool like the generators themselves: it is not part of the game or of
the build, only the .ogg files it writes are. Loops stay seamless because the decoder, not the
file, loops them (the import sets loop=true, loop_offset=0.0); `verify_loop` compares the decoded
file with its source and the size of the jump at the wrap, so a bad encode is found here.
"""
import os
import shutil
import subprocess
import wave

import numpy as np

QUALITY = 5


def ffmpeg():
    path = shutil.which("ffmpeg")
    if path is None:
        raise SystemExit("ffmpeg is needed to encode Ogg Vorbis (dev tool, ADR-057): install it and run again")
    return path


def to_ogg(wav_path, ogg_path, quality=QUALITY):
    """Encodes `wav_path` as Ogg Vorbis (libvorbis, `quality` 0-10) at `ogg_path`."""
    command = [ffmpeg(), "-loglevel", "error", "-y", "-i", wav_path, "-map_metadata", "-1", "-c:a", "libvorbis",
               "-q:a", str(quality), "-bitexact", "-fflags", "+bitexact", ogg_path]
    subprocess.run(command, check=True)


def decode(path):
    """(samples as float array [channels, n], rate) of any audio file, decoded by ffmpeg to 16-bit PCM."""
    probe = subprocess.run([ffmpeg(), "-loglevel", "error", "-i", path, "-f", "s16le", "-acodec", "pcm_s16le", "-"],
                           check=True, capture_output=True).stdout
    channels = channel_count(path)
    data = np.frombuffer(probe, dtype="<i2").astype(np.float64) / 32768.0
    return data.reshape(-1, channels).T, sample_rate(path)


def channel_count(path):
    if path.endswith(".wav"):
        with wave.open(path, "rb") as w:
            return w.getnchannels()
    out = subprocess.run([shutil.which("ffprobe") or "ffprobe", "-v", "error", "-select_streams", "a:0", "-show_entries",
                          "stream=channels", "-of", "csv=p=0", path], check=True, capture_output=True, text=True)
    return int(out.stdout.strip())


def sample_rate(path):
    if path.endswith(".wav"):
        with wave.open(path, "rb") as w:
            return w.getframerate()
    out = subprocess.run([shutil.which("ffprobe") or "ffprobe", "-v", "error", "-select_streams", "a:0", "-show_entries",
                          "stream=sample_rate", "-of", "csv=p=0", path], check=True, capture_output=True, text=True)
    return int(out.stdout.strip())


def verify_loop(wav_path, ogg_path, max_length_error=0.001, max_seam_ratio=4.0):
    """Problems of an encoded loop: its length differs from the source, or the wrap is louder than the music.

    The seam is the jump from the last decoded sample to the first; it is compared with the largest
    jump between neighbouring samples inside the source. Empty list: the loop is fine.
    """
    with wave.open(wav_path, "rb") as w:
        source = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64) / 32768.0
        source = source.reshape(-1, w.getnchannels()).T
    decoded, _ = decode(ogg_path)
    problems = []
    if abs(decoded.shape[1] - source.shape[1]) > max_length_error * source.shape[1]:
        problems.append("length %d samples, source has %d" % (decoded.shape[1], source.shape[1]))
        return problems
    jump = np.max(np.abs(decoded[:, 0] - decoded[:, -1]))
    inside = np.max(np.abs(np.diff(source, axis=1)))
    if jump > max_seam_ratio * inside:
        problems.append("the seam jumps %.4f, the music itself %.4f" % (jump, inside))
    return problems
