"""Synthesizes Sky Coin Obby's original chiptune music and sound effects.

Usage: python3 tools/make_audio.py   (needs numpy + ffmpeg)
Writes .mp3 files to audio/. Everything is generated from scratch, so it's
copyright-free and safe to upload to Roblox.
"""
import os
import subprocess
import tempfile
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "audio")
NOTE = {n: i for i, n in enumerate(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])}


def hz(name):
    """'A4' -> 440.0, 'C#5' -> ..."""
    pitch, octave = name[:-1], int(name[-1])
    midi = NOTE[pitch] + (octave + 1) * 12
    return 440.0 * 2 ** ((midi - 69) / 12)


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def t(seconds):
    return np.arange(int(SR * seconds)) / SR


# ---------------------------------------------------------------- oscillators
def pulse(freq, seconds, duty=0.5):
    phase = np.cumsum(np.broadcast_to(freq, t(seconds).shape) / SR) % 1.0
    return np.where(phase < duty, 1.0, -1.0)


def triangle(freq, seconds):
    phase = np.cumsum(np.broadcast_to(freq, t(seconds).shape) / SR) % 1.0
    return 4 * np.abs(phase - 0.5) - 1


def sine(freq, seconds):
    phase = np.cumsum(np.broadcast_to(freq, t(seconds).shape) / SR)
    return np.sin(2 * np.pi * phase)


def noise(seconds, seed=0):
    return np.random.default_rng(seed).uniform(-1, 1, int(SR * seconds))


def env(n, attack=0.005, decay=0.1, sustain=0.6, release=0.05):
    """ADSR envelope over n samples."""
    a, d, r = int(attack * SR), int(decay * SR), int(release * SR)
    s = max(n - a - d - r, 0)
    curve = np.concatenate([
        np.linspace(0, 1, a, endpoint=False),
        np.linspace(1, sustain, d, endpoint=False),
        np.full(s, sustain),
        np.linspace(sustain, 0, r),
    ])
    return np.pad(curve, (0, max(n - len(curve), 0)))[:n]


def expdecay(n, rate):
    return np.exp(-np.arange(n) / SR * rate)


def place(buf, sig, start):
    i = int(start * SR)
    end = min(i + len(sig), len(buf))
    if i < len(buf):
        buf[i:end] += sig[: end - i]


# ---------------------------------------------------------------- output
def write_mp3(name, sig, peak_db=-1.0):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * 10 ** (peak_db / 20)
    os.makedirs(OUT, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        path = tmp.name
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((sig * 32767).astype(np.int16).tobytes())
    dest = os.path.join(OUT, name + ".mp3")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", path, "-c:a", "libmp3lame", "-b:a", "192k", dest], check=True)
    os.remove(path)
    print("wrote", dest, f"{len(sig) / SR:.1f}s")


# ---------------------------------------------------------------- sound effects
def sfx_coin():
    a = pulse(hz("B5"), 0.07, 0.25) * env(int(0.07 * SR), 0.002, 0.02, 0.8, 0.01)
    b = pulse(hz("E6"), 0.35, 0.25) * expdecay(int(0.35 * SR), 9)
    return np.concatenate([a, b])


def sfx_checkpoint():
    out = np.zeros(int(SR * 0.9))
    for i, n in enumerate(["C5", "E5", "G5", "C6"]):
        length = 0.5 if i == 3 else 0.12
        tone = 0.6 * pulse(hz(n), length, 0.5) + 0.4 * triangle(hz(n) * 2, length)
        place(out, tone * expdecay(len(tone), 4 if i == 3 else 18), i * 0.075)
    return out


def sfx_purchase():
    out = np.zeros(int(SR * 0.9))
    place(out, 0.5 * noise(0.06, 1) * expdecay(int(0.06 * SR), 60), 0)
    for i, f in enumerate([hz("G6"), hz("C7")]):
        bell = sine(f, 0.7) + 0.5 * sine(f * 2.76, 0.7) + 0.25 * sine(f * 5.4, 0.7)
        place(out, bell * expdecay(len(bell), 6), 0.05 + i * 0.09)
    return out


def sfx_death():
    n = int(0.45 * SR)
    sweep = np.geomspace(700, 90, n)
    body = pulse(sweep, 0.45, 0.5) * env(n, 0.002, 0.05, 0.7, 0.15)
    pop = noise(0.08, 2) * expdecay(int(0.08 * SR), 40)
    out = np.zeros(n)
    out += 0.7 * body
    place(out, 0.6 * pop, 0)
    return out


def sfx_win():
    out = np.zeros(int(SR * 2.4))
    for i, n in enumerate(["G4", "C5", "E5", "G5"]):
        tone = pulse(hz(n), 0.14, 0.25) * env(int(0.14 * SR), 0.003, 0.04, 0.7, 0.02)
        place(out, tone, i * 0.13)
    vib = 1 + 0.006 * np.sin(2 * np.pi * 6 * t(1.8))
    for n in ["C5", "E5", "G5", "C6"]:
        tone = pulse(hz(n) * vib, 1.8, 0.25 if n != "C6" else 0.5)
        place(out, 0.35 * tone * env(len(tone), 0.01, 0.3, 0.6, 0.9), 0.55)
    return out


def sfx_jumppad():
    n = int(0.4 * SR)
    sweep = np.geomspace(140, 620, n) * (1 + 0.08 * np.sin(2 * np.pi * 18 * t(0.4)))
    return (0.7 * sine(sweep, 0.4) + 0.3 * triangle(sweep, 0.4)) * env(n, 0.003, 0.1, 0.6, 0.15)


def sfx_click():
    return pulse(hz("A6"), 0.04, 0.5) * expdecay(int(0.04 * SR), 60)


def sfx_daily():
    out = np.zeros(int(SR * 1.2))
    for i, n in enumerate(["E5", "G#5", "B5", "E6", "G#6", "B6"]):
        tone = triangle(hz(n), 0.5) + 0.4 * pulse(hz(n), 0.5, 0.125)
        place(out, tone * expdecay(len(tone), 7), i * 0.06)
    return out


# ---------------------------------------------------------------- music
SCALES = {"major": [0, 2, 4, 5, 7, 9, 11], "minor": [0, 2, 3, 5, 7, 8, 10]}


def kick():
    n = int(0.18 * SR)
    return sine(np.geomspace(160, 45, n), 0.18) * expdecay(n, 18)


def snare(seed):
    n = int(0.16 * SR)
    return (0.8 * noise(0.16, seed) + 0.3 * triangle(190, 0.16)) * expdecay(n, 22)


def hat(seed):
    n = int(0.04 * SR)
    hp = np.diff(noise(0.041, seed))[:n]
    return hp * expdecay(n, 80)


def song(name, root_midi, scale, bpm, progression, sections, seed, lead_duty=0.25, arp=True, swing=0.0):
    """progression: chord degrees (0-based scale steps) per bar; sections: list of section letters.
    Melody motifs are generated once per section letter, so repeated sections repeat (catchy)."""
    rng = np.random.default_rng(seed)
    steps = SCALES[scale]
    beat = 60 / bpm
    bar = beat * 4
    bars_per_section = len(progression)
    total_bars = bars_per_section * len(sections)
    out = np.zeros(int(SR * bar * total_bars) + SR)

    def degree_midi(deg, octave_shift=0):
        o, d = divmod(deg, 7)
        return root_midi + steps[d] + 12 * (o + octave_shift)

    rhythms = [
        [1, 0.5, 0.5, 1, 1],
        [0.5, 0.5, 0.5, 0.5, 1, 1],
        [1.5, 0.5, 1, 1],
        [0.5, 0.5, 1, 0.5, 0.5, 1],
        [1, 1, 0.5, 0.5, 1],
    ]
    motifs = {}
    for letter in dict.fromkeys(sections):
        bars = []
        for b in range(bars_per_section):
            rhythm = rhythms[rng.integers(len(rhythms))]
            notes = []
            for i, _ in enumerate(rhythm):
                if i == 0 or rng.random() < 0.55:
                    notes.append(int(rng.choice([0, 2, 4, 7])))  # chord tones (relative)
                else:
                    notes.append(int(rng.choice([1, 3, 5, 6])))  # passing tones
            if rng.random() < 0.25:
                notes[-1] = None  # rest for breathing room
            bars.append((rhythm, notes))
        motifs[letter] = bars

    for s, letter in enumerate(sections):
        for b in range(bars_per_section):
            bar_index = s * bars_per_section + b
            start = bar_index * bar
            chord = progression[b]

            # drums
            for q in range(4):
                if q in (0, 2):
                    place(out, 0.9 * kick(), start + q * beat)
                else:
                    place(out, 0.55 * snare(bar_index * 4 + q), start + q * beat)
                for e in range(2):
                    off = swing * beat * 0.5 if e == 1 else 0
                    place(out, 0.18 * hat(bar_index * 8 + q * 2 + e), start + q * beat + e * beat / 2 + off)

            # bass: root/fifth eighths
            for e in range(8):
                deg = chord if e % 4 != 3 else chord + 4
                f = midi_hz(degree_midi(deg, -2))
                tone = triangle(f, beat / 2 * 0.9)
                place(out, 0.55 * tone * env(len(tone), 0.003, 0.05, 0.8, 0.02), start + e * beat / 2)

            # arpeggio pad
            if arp:
                chord_tones = [chord, chord + 2, chord + 4, chord + 7]
                for sx in range(16):
                    f = midi_hz(degree_midi(chord_tones[sx % 4], 0))
                    tone = pulse(f, beat / 4 * 0.8, 0.5)
                    place(out, 0.12 * tone * expdecay(len(tone), 25), start + sx * beat / 4)

            # lead melody
            rhythm, notes = motifs[letter][b]
            pos = 0.0
            for dur, rel in zip(rhythm, notes):
                if rel is not None:
                    f = midi_hz(degree_midi(chord + rel, 1))
                    length = dur * beat * 0.92
                    vib = 1 + 0.004 * np.sin(2 * np.pi * 5.5 * t(length))
                    tone = pulse(f * vib, length, lead_duty)
                    place(out, 0.3 * tone * env(len(tone), 0.005, 0.08, 0.65, 0.04), start + pos * beat)
                pos += dur

    loop_len = int(SR * bar * total_bars)
    # fold the tail back to the start so the loop is seamless
    tail = out[loop_len:]
    out = out[:loop_len]
    out[: len(tail)] += tail
    return out


def main():
    write_mp3("sfx_coin", sfx_coin())
    write_mp3("sfx_checkpoint", sfx_checkpoint())
    write_mp3("sfx_purchase", sfx_purchase())
    write_mp3("sfx_death", sfx_death())
    write_mp3("sfx_win", sfx_win())
    write_mp3("sfx_jumppad", sfx_jumppad())
    write_mp3("sfx_click", sfx_click())
    write_mp3("sfx_daily", sfx_daily())

    # Zone 1 - Sky: bright, upbeat C major (I V vi IV)
    write_mp3("music_sky", song("sky", 60, "major", 140, [0, 4, 5, 3], list("AABACCBA"), seed=7), peak_db=-3)
    # Zone 2 - Candy: bouncy F major with swing (I vi ii V)
    write_mp3("music_candy", song("candy", 65, "major", 150, [0, 5, 1, 4], list("AABBCABA"), seed=21, lead_duty=0.125, swing=0.33), peak_db=-3)
    # Zone 3 - Space: dreamy A minor (i VI III VII)
    write_mp3("music_space", song("space", 57, "minor", 112, [0, 5, 2, 6], list("AABACABA"), seed=42, lead_duty=0.5), peak_db=-3)


if __name__ == "__main__":
    main()
