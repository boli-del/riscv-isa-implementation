# RISC-V Modules — Contributing

This repo holds our RISC-V RTL and its verification suite. Hardware is written in Verilog and tested with **cocotb** (Python testbenches) running on the **Icarus Verilog** simulator. Every push is checked automatically by GitHub Actions, so the goal of this guide is to get you set up locally so your tests pass *before* they hit CI.

---

## 1. Prerequisites

You need three things installed.

**Python 3.13 — not 3.14.** This matters: cocotb 2.0.1 only supports up to Python 3.13, and installing on 3.14 fails outright. If you have multiple Pythons on Windows, use the launcher to target the right one:

```
py -3.13 -m venv venv
```

**Icarus Verilog** — the simulator cocotb drives. It is *not* a pip package.
- Linux: `sudo apt-get install iverilog`
- macOS: `brew install icarus-verilog`
- Windows: installer at https://bleyer.org/icarus

**The Python dependencies**, via the pinned `requirements.txt` (see setup below).

---

## 2. Local setup

From the repo root:

```
py -3.13 -m venv venv          # create a virtual environment on Python 3.13
venv\Scripts\activate          # Windows  (use: source venv/bin/activate on Linux/macOS)
pip install -r requirements.txt
```

**Windows note:** if activation fails with a "running scripts is disabled" error, run this once in PowerShell — it's a default security setting, not a project problem:

```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Verify the install:

```
python -c "import cocotb; print(cocotb.__version__)"
iverilog -V
```

---

## 3. How the tests work (cocotb in 60 seconds)

cocotb lets us write testbenches in Python instead of SystemVerilog. cocotb itself does **not** simulate — it drives an external simulator (Icarus, for us) and pokes/checks signals on the design under test (the `dut`).

There are two layers of "test discovery", and it's worth understanding both:

1. **Test functions.** Inside a test module, every function decorated with `@cocotb.test()` is collected and run automatically. You don't list them anywhere.
2. **The runner.** Each Verilog top module has to be paired with its Python test module — cocotb can't guess that mapping. That pairing lives in the `TESTBENCHES` list in `testbenches/test_runner.py`. pytest runs every row in that list.

So adding a new testbench is a three-step process:

1. Write your RTL under the source directory (e.g. `rtl/`).
2. Write a Python test file with one or more `@cocotb.test()` functions (e.g. `testbenches/test_mystage.py`).
3. Add a row to `TESTBENCHES` mapping the two:

```python
TESTBENCHES = [
    ("fetch_stage",  ["fetch_stage.v"],  "test_fetch"),
    ("my_stage",     ["my_stage.v"],     "test_mystage"),   # <- new row
]
```

### Testbench conventions

A few things we've standardized on, so tests stay consistent:

- **Always start the clock** at the top of a test: `Clock(dut.clk, period=2, unit="ns").start()`. (Note: it's `unit`, singular, in cocotb 2.0 — `units` was the old 1.x spelling.)
- **Read and write values through `.value`** — `dut.sig.value == 0`, not `dut.sig == 0`.
- **Async reset** is active-low (`rst_n`). Pulling it low clears registers immediately, independent of the clock, so a small `await Timer(1, unit="ns")` to let it propagate is enough — no clock edge required for reset itself.
- **Memory/array access** (register files, instruction memory) works by indexing the handle, then setting `.value`: `dut.reg_file[5].value = 0xDEADBEEF`. This relies on Icarus exposing internal arrays, which it does — another reason we standardize on Icarus.
- **Assert messages** should describe the *failure*, with actual vs expected, e.g. `assert dut.x.value == exp, f"x mismatch: got {dut.x.value}, expected {exp}"`.

---

## 4. Running tests locally

Run the whole suite the same way CI does:

```
pytest -v testbenches/test_runner.py
```

A failing cocotb assertion exits nonzero, which fails the run — same signal CI uses. Run this before every push.

---

## 5. The automated check (GitHub Actions)

Every push triggers `.github/workflows/run-test.yml`. On a fresh Ubuntu VM it:

1. Checks out the repo
2. Sets up Python 3.13
3. Installs Icarus Verilog
4. Installs dependencies from `requirements.txt`
5. Runs `pytest -v testbenches/test_runner.py`

**Pass/fail is by exit code.** If any testbench assertion fails, the run goes red, you get a red ✗ on your commit, and (where branch protection is on) the PR can't merge until it's green. That's the point — it keeps broken RTL off the main branch.

### One gotcha worth knowing

We develop on **Windows** but CI runs on **Linux**. The Windows and Linux builds of Icarus support slightly different subsets of SystemVerilog, so occasionally RTL that compiles fine on your machine throws a syntax error in CI on a newer SV feature. If a push fails in CI but passed locally, this mismatch is the usual suspect — check the Actions tab log for the exact line.

To debug a failed run, the waveform traces (`.fst`) are uploaded as artifacts even on failure — download them from the run page and open in GTKWave.

---

## 6. Contribution workflow

1. **Branch** off main: `git checkout -b feature/your-thing`
2. **Write the RTL and its testbench**, and add the row to `TESTBENCHES`.
3. **Run `pytest -v testbenches/test_runner.py` locally** until it's green.
4. **Commit and push.** CI runs automatically.
5. **Open a PR** and wait for the green check before merging.

Keep RTL changes and their tests in the same PR — a module without a passing testbench shouldn't land. If you're adding a new Python dependency, add it to `requirements.txt` (pin cocotb's version) so everyone and CI install the same thing.

---

## Quick reference

| Task | Command |
|------|---------|
| Create env | `py -3.13 -m venv venv` |
| Activate (Windows) | `venv\Scripts\activate` |
| Install deps | `pip install -r requirements.txt` |
| Run all tests | `pytest -v testbenches/test_runner.py` |
| Check cocotb version | `python -c "import cocotb; print(cocotb.__version__)"` |

Questions about a specific testbench or the CI setup — ask before pushing a workaround; usually there's a convention for it already.
