"""Generate WAV audio files for SpaceTrader — dubstep music + SFX."""
import struct, math, os, random

SAMPLE_RATE = 44100

def create_wav(samples, sample_rate=SAMPLE_RATE, channels=1):
    """Create a WAV file from a list of float samples (-1.0 to 1.0)."""
    num_samples = len(samples)
    bits_per_sample = 16
    byte_rate = sample_rate * channels * bits_per_sample // 8
    block_align = channels * bits_per_sample // 8
    data_size = num_samples * block_align

    raw = b''
    for s in samples:
        s = max(-1.0, min(1.0, s))
        raw += struct.pack('<h', int(s * 32767))

    header = struct.pack('<4sI4s', b'RIFF', 36 + data_size, b'WAVE')
    fmt = struct.pack('<4sIHHIIHH', b'fmt ', 16, 1, channels, sample_rate,
                      byte_rate, block_align, bits_per_sample)
    data = struct.pack('<4sI', b'data', data_size) + raw
    return header + fmt + data


# ─── Helper functions ───

def sine(freq, t):
    return math.sin(2 * math.pi * freq * t)

def square(freq, t):
    return 1.0 if sine(freq, t) >= 0 else -1.0

def saw(freq, t):
    phase = (freq * t) % 1.0
    return 2.0 * phase - 1.0

def noise():
    return random.uniform(-1, 1)

def envelope(t, attack, decay, sustain, release, duration):
    """ADSR envelope."""
    if t < attack:
        return t / attack
    elif t < attack + decay:
        return 1.0 - (1.0 - sustain) * ((t - attack) / decay)
    elif t < duration - release:
        return sustain
    elif t < duration:
        return sustain * (1.0 - (t - (duration - release)) / release)
    return 0.0

def lowpass(samples, cutoff_freq, sample_rate=SAMPLE_RATE):
    """Simple one-pole lowpass filter."""
    rc = 1.0 / (2.0 * math.pi * cutoff_freq)
    dt = 1.0 / sample_rate
    alpha = dt / (rc + dt)
    out = [0.0] * len(samples)
    out[0] = samples[0] * alpha
    for i in range(1, len(samples)):
        out[i] = out[i-1] + alpha * (samples[i] - out[i-1])
    return out

def distort(samples, gain=2.0):
    """Soft clipping distortion."""
    return [math.tanh(s * gain) for s in samples]


# ═══════════════════════════════════════════════════════
# DUBSTEP MUSIC — ~16 bar loop (~17 seconds at 140 BPM)
# ═══════════════════════════════════════════════════════

def make_music():
    bpm = 140
    beats_per_bar = 4
    num_bars = 16
    total_beats = num_bars * beats_per_bar
    beat_duration = 60.0 / bpm
    total_duration = total_beats * beat_duration
    num_samples = int(total_duration * SAMPLE_RATE)
    samples = [0.0] * num_samples

    random.seed(808)

    # ── KICK DRUM ── hits on beats 1 and 3 of each bar
    for bar in range(num_bars):
        for beat_in_bar in [0, 2]:
            beat = bar * beats_per_bar + beat_in_bar
            start = beat * beat_duration
            kick_len = 0.3
            for i in range(int(kick_len * SAMPLE_RATE)):
                t = i / SAMPLE_RATE
                if int((start + t) * SAMPLE_RATE) < num_samples:
                    idx = int((start + t) * SAMPLE_RATE)
                    # Pitch drops from 150Hz to 40Hz
                    freq = 150 * math.exp(-t * 12) + 40
                    env = math.exp(-t * 8)
                    samples[idx] += sine(freq, t) * env * 0.6

    # ── SNARE ── beats 2 and 4
    for bar in range(num_bars):
        for beat_in_bar in [1, 3]:
            beat = bar * beats_per_bar + beat_in_bar
            start = beat * beat_duration
            snare_len = 0.15
            for i in range(int(snare_len * SAMPLE_RATE)):
                t = i / SAMPLE_RATE
                if int((start + t) * SAMPLE_RATE) < num_samples:
                    idx = int((start + t) * SAMPLE_RATE)
                    env = math.exp(-t * 20)
                    # Noise + tone
                    samples[idx] += (noise() * 0.5 + sine(200, t) * 0.3) * env * 0.4

    # ── HI-HATS ── eighth notes
    for beat in range(total_beats * 2):
        start = beat * beat_duration / 2
        hat_len = 0.05
        for i in range(int(hat_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((start + t) * SAMPLE_RATE)
            if idx < num_samples:
                env = math.exp(-t * 60)
                samples[idx] += noise() * env * 0.12

    # ── WOBBLE BASS ── the signature dubstep sound
    # Plays during bars 4-8 and 12-16 (the "drops")
    drop_bars = list(range(4, 8)) + list(range(12, 16))
    # Bass note pattern (in Hz) — sub-bass frequencies
    bass_notes = [55, 55, 65.41, 55, 49, 49, 55, 65.41]  # A1, A1, C2, A1, G1, G1, A1, C2

    for bar in drop_bars:
        bar_start = bar * beats_per_bar * beat_duration
        note_freq = bass_notes[bar % len(bass_notes)]
        bar_len = beats_per_bar * beat_duration

        for i in range(int(bar_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((bar_start + t) * SAMPLE_RATE)
            if idx < num_samples:
                # LFO wobble rate varies — faster = more aggressive
                wobble_rate = 4.0 + 3.0 * sine(0.5, bar_start + t)
                wobble = (sine(wobble_rate, t) + 1.0) / 2.0  # 0 to 1

                # Modulate filter cutoff with wobble
                cutoff_mod = 200 + wobble * 2000

                # Distorted saw wave
                raw = saw(note_freq, t) * 0.7 + saw(note_freq * 2, t) * 0.3
                # Simple "filter" approximation via mixing with sine
                filtered = raw * wobble + sine(note_freq, t) * (1.0 - wobble)
                filtered = math.tanh(filtered * 2.0)  # soft clip

                env = min(1.0, t * 10) * min(1.0, (bar_len - t) * 10)
                samples[idx] += filtered * env * 0.35

    # ── SYNTH MELODY ── plays during bars 0-4 and 8-12 (buildup sections)
    # Simple arpeggiated pattern
    melody_notes = [
        # (beat_offset, freq, duration)
        (0, 440, 0.5), (0.5, 523.25, 0.5), (1, 659.25, 0.5), (1.5, 523.25, 0.5),
        (2, 440, 0.5), (2.5, 349.23, 0.5), (3, 392, 0.75), (3.75, 440, 0.25),
    ]
    buildup_bars = list(range(0, 4)) + list(range(8, 12))

    for bar in buildup_bars:
        bar_start = bar * beats_per_bar * beat_duration
        for beat_off, freq, dur in melody_notes:
            note_start = bar_start + beat_off * beat_duration
            note_len = dur * beat_duration

            for i in range(int(note_len * SAMPLE_RATE)):
                t = i / SAMPLE_RATE
                idx = int((note_start + t) * SAMPLE_RATE)
                if idx < num_samples:
                    env = envelope(t, 0.01, 0.05, 0.6, 0.1, note_len)
                    # Detuned square waves for that synth sound
                    val = square(freq, t) * 0.5 + square(freq * 1.005, t) * 0.3 + sine(freq * 0.5, t) * 0.2
                    samples[idx] += val * env * 0.15

    # ── SUB BASS ── constant low drone during drops for weight
    for bar in drop_bars:
        bar_start = bar * beats_per_bar * beat_duration
        note_freq = bass_notes[bar % len(bass_notes)] / 2  # one octave lower
        bar_len = beats_per_bar * beat_duration
        for i in range(int(bar_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((bar_start + t) * SAMPLE_RATE)
            if idx < num_samples:
                env = min(1.0, t * 5) * min(1.0, (bar_len - t) * 5)
                samples[idx] += sine(note_freq, t) * env * 0.25

    # ── RISERS ── sweep noise before drops (bars 3 and 11)
    for riser_bar in [3, 11]:
        riser_start = riser_bar * beats_per_bar * beat_duration
        riser_len = beats_per_bar * beat_duration
        for i in range(int(riser_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((riser_start + t) * SAMPLE_RATE)
            if idx < num_samples:
                progress = t / riser_len
                freq = 200 + progress * 3000
                vol = progress * 0.2
                samples[idx] += sine(freq, t) * vol

    # Master limiting
    peak = max(abs(s) for s in samples) or 1.0
    samples = [s / peak * 0.85 for s in samples]

    return create_wav(samples)


# ═══════════════════════════════════════════
# SOUND EFFECTS
# ═══════════════════════════════════════════

def make_sfx_shoot():
    """Blaster shot — quick zap."""
    dur = 0.15
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 800 - t * 3000  # descending pitch
        env = math.exp(-t * 25)
        samples.append((sine(freq, t) * 0.6 + square(freq * 1.5, t) * 0.2) * env)
    return create_wav(samples)

def make_sfx_laser():
    """Laser pew — high pitched sine sweep."""
    dur = 0.1
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 1500 - t * 5000
        env = math.exp(-t * 20)
        samples.append(sine(freq, t) * env * 0.4)
    return create_wav(samples)

def make_sfx_spread():
    """Spread shot — chunky burst."""
    dur = 0.2
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 400 - t * 1000
        env = math.exp(-t * 15)
        samples.append((saw(freq, t) * 0.4 + noise() * 0.3) * env)
    return create_wav(samples)

def make_sfx_explosion():
    """Explosion — noise burst with low rumble."""
    dur = 0.6
    n = int(dur * SAMPLE_RATE)
    samples = []
    random.seed(99)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 5)
        rumble = sine(60 + 40 * math.exp(-t * 3), t) * 0.5
        crackle = noise() * 0.5
        samples.append((rumble + crackle) * env)
    samples = lowpass(samples, 2000)
    return create_wav(samples)

def make_sfx_pickup():
    """Item pickup — ascending chime."""
    dur = 0.25
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 600 + t * 1200
        env = envelope(t, 0.01, 0.05, 0.5, 0.1, dur)
        samples.append(sine(freq, t) * env * 0.4)
    return create_wav(samples)

def make_sfx_hit():
    """Ship taking damage — metallic clang."""
    dur = 0.2
    n = int(dur * SAMPLE_RATE)
    samples = []
    random.seed(77)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 20)
        # Metallic: multiple inharmonic frequencies
        val = (sine(300, t) * 0.3 + sine(743, t) * 0.3 +
               sine(1100, t) * 0.2 + noise() * 0.2)
        samples.append(val * env)
    return create_wav(samples)

def make_sfx_death():
    """Ship destroyed — big boom + descending tone."""
    dur = 1.0
    n = int(dur * SAMPLE_RATE)
    samples = []
    random.seed(42)
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3)
        freq = 200 * math.exp(-t * 2) + 30
        val = (sine(freq, t) * 0.4 + saw(freq * 0.5, t) * 0.2 + noise() * 0.4)
        samples.append(val * env * 0.7)
    samples = lowpass(samples, 1500)
    return create_wav(samples)

def make_sfx_trade():
    """Trade/purchase — cash register ding."""
    dur = 0.3
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 8)
        # Two bright tones
        val = sine(1200, t) * 0.4 + sine(1800, t) * 0.3
        samples.append(val * env)
    return create_wav(samples)

def make_sfx_mine():
    """Mining — rhythmic clink."""
    dur = 0.15
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 30)
        val = sine(800, t) * 0.3 + sine(1600, t) * 0.3 + noise() * 0.15
        samples.append(val * env)
    return create_wav(samples)

def make_sfx_win():
    """Victory fanfare — ascending chord."""
    dur = 1.5
    n = int(dur * SAMPLE_RATE)
    samples = []
    # Three ascending notes
    notes = [(0.0, 523.25, 0.5), (0.3, 659.25, 0.5), (0.6, 783.99, 0.9)]
    for i in range(n):
        t = i / SAMPLE_RATE
        val = 0.0
        for start, freq, length in notes:
            if start <= t < start + length:
                nt = t - start
                env = envelope(nt, 0.02, 0.1, 0.7, 0.2, length)
                val += (sine(freq, t) * 0.4 + sine(freq * 2, t) * 0.15) * env
        samples.append(val * 0.5)
    return create_wav(samples)

def make_sfx_gameover():
    """Game over — descending sad tones."""
    dur = 1.5
    n = int(dur * SAMPLE_RATE)
    samples = []
    notes = [(0.0, 392, 0.5), (0.4, 349.23, 0.5), (0.8, 293.66, 0.7)]
    for i in range(n):
        t = i / SAMPLE_RATE
        val = 0.0
        for start, freq, length in notes:
            if start <= t < start + length:
                nt = t - start
                env = envelope(nt, 0.02, 0.1, 0.6, 0.3, length)
                val += sine(freq, t) * 0.4 * env
        samples.append(val * 0.5)
    return create_wav(samples)

def make_sfx_enemy_shoot():
    """Enemy shooting — lower, more menacing."""
    dur = 0.12
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 500 - t * 2000
        env = math.exp(-t * 22)
        samples.append((saw(freq, t) * 0.4 + noise() * 0.15) * env)
    return create_wav(samples)


# ═══════════════════════════════════════════════════════
# INDUSTRIAL BOSS MUSIC — heavy, mechanical, aggressive
# ═══════════════════════════════════════════════════════

def make_boss_music():
    bpm = 150
    beats_per_bar = 4
    num_bars = 16
    total_beats = num_bars * beats_per_bar
    beat_duration = 60.0 / bpm
    total_duration = total_beats * beat_duration
    num_samples = int(total_duration * SAMPLE_RATE)
    samples = [0.0] * num_samples

    random.seed(666)

    # ── HEAVY KICK ── every beat, with distortion
    for beat in range(total_beats):
        start = beat * beat_duration
        kick_len = 0.25
        for i in range(int(kick_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((start + t) * SAMPLE_RATE)
            if idx < num_samples:
                freq = 180 * math.exp(-t * 15) + 35
                env = math.exp(-t * 6)
                val = sine(freq, t) * 0.7 + saw(freq * 0.5, t) * 0.2
                samples[idx] += math.tanh(val * 2.5) * env * 0.5

    # ── INDUSTRIAL SNARE ── beats 2 and 4, metallic noise
    for bar in range(num_bars):
        for beat_in_bar in [1, 3]:
            beat = bar * beats_per_bar + beat_in_bar
            start = beat * beat_duration
            snare_len = 0.2
            for i in range(int(snare_len * SAMPLE_RATE)):
                t = i / SAMPLE_RATE
                idx = int((start + t) * SAMPLE_RATE)
                if idx < num_samples:
                    env = math.exp(-t * 15)
                    val = (noise() * 0.6 + sine(350, t) * 0.2 +
                           sine(887, t) * 0.15 + square(200, t) * 0.1)
                    samples[idx] += val * env * 0.4

    # ── MECHANICAL HI-HATS ── sixteenth notes, harsh
    for beat in range(total_beats * 4):
        start = beat * beat_duration / 4
        hat_len = 0.03
        for i in range(int(hat_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((start + t) * SAMPLE_RATE)
            if idx < num_samples:
                env = math.exp(-t * 80)
                samples[idx] += noise() * env * 0.1

    # ── DISTORTED BASS ── aggressive, grinding
    bass_pattern = [55, 55, 41.2, 55, 49, 49, 36.7, 41.2]
    for bar in range(num_bars):
        bar_start = bar * beats_per_bar * beat_duration
        note_freq = bass_pattern[bar % len(bass_pattern)]
        bar_len = beats_per_bar * beat_duration

        for i in range(int(bar_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((bar_start + t) * SAMPLE_RATE)
            if idx < num_samples:
                raw = saw(note_freq, t) * 0.5 + square(note_freq, t) * 0.3 + saw(note_freq * 2.01, t) * 0.2
                distorted = math.tanh(raw * 3.0)
                gate_phase = (t / beat_duration * 2) % 1.0
                gate = 1.0 if gate_phase < 0.7 else 0.2
                env = min(1.0, t * 8) * min(1.0, (bar_len - t) * 8)
                samples[idx] += distorted * env * gate * 0.3

    # ── INDUSTRIAL NOISE HITS ── mechanical clangs on bar starts
    for bar in range(num_bars):
        if bar % 2 == 0:
            start = bar * beats_per_bar * beat_duration
            clang_len = 0.4
            random.seed(bar * 7)
            for i in range(int(clang_len * SAMPLE_RATE)):
                t = i / SAMPLE_RATE
                idx = int((start + t) * SAMPLE_RATE)
                if idx < num_samples:
                    env = math.exp(-t * 8)
                    val = (sine(440, t) * 0.2 + sine(1174, t) * 0.15 +
                           sine(2637, t) * 0.1 + noise() * 0.3)
                    samples[idx] += val * env * 0.25

    # ── ALARM SIREN ── subtle background tension
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        siren_freq = 300 + 100 * sine(1.5, t)
        samples[i] += sine(siren_freq, t) * 0.04

    # ── POWER SURGE RISERS ── before every 4th bar
    for bar in [3, 7, 11, 15]:
        riser_start = bar * beats_per_bar * beat_duration
        riser_len = beats_per_bar * beat_duration
        for i in range(int(riser_len * SAMPLE_RATE)):
            t = i / SAMPLE_RATE
            idx = int((riser_start + t) * SAMPLE_RATE)
            if idx < num_samples:
                progress = t / riser_len
                freq = 100 + progress * 4000
                vol = progress * 0.15
                samples[idx] += (saw(freq, t) * 0.6 + noise() * 0.4) * vol

    peak = max(abs(s) for s in samples) or 1.0
    samples = [s / peak * 0.85 for s in samples]
    return create_wav(samples)


def make_sfx_boss_warning():
    """Boss incoming warning — dramatic alarm."""
    dur = 2.0
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        pulse = int(t / 0.5) % 2
        if pulse == 0:
            freq = 600 + 200 * sine(8, t)
            val = (sine(freq, t) * 0.5 + square(freq * 0.5, t) * 0.2)
            samples.append(val * 0.5)
        else:
            samples.append(0.0)
    for i in range(len(samples)):
        t = i / SAMPLE_RATE
        if t > 1.5:
            samples[i] *= 1.0 - (t - 1.5) / 0.5
    return create_wav(samples)


# ─── Write all audio ───
os.makedirs('assets/sounds', exist_ok=True)

audio_files = {
    'music_space': make_music,
    'music_boss': make_boss_music,
    'sfx_shoot': make_sfx_shoot,
    'sfx_laser': make_sfx_laser,
    'sfx_spread': make_sfx_spread,
    'sfx_explosion': make_sfx_explosion,
    'sfx_pickup': make_sfx_pickup,
    'sfx_hit': make_sfx_hit,
    'sfx_death': make_sfx_death,
    'sfx_trade': make_sfx_trade,
    'sfx_mine': make_sfx_mine,
    'sfx_win': make_sfx_win,
    'sfx_gameover': make_sfx_gameover,
    'sfx_enemy_shoot': make_sfx_enemy_shoot,
    'sfx_boss_warning': make_sfx_boss_warning,
}

print("Generating audio...")
for name, func in audio_files.items():
    data = func()
    with open(f'assets/sounds/{name}.wav', 'wb') as f:
        f.write(data)
    size = len(data)
    print(f"  {name}.wav: {size:,} bytes")

print("All audio generated!")
