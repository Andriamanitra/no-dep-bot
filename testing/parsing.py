import sys
from subprocess import Popen, PIPE

parsers = {
    "julia": ["julia", "julia/test_parse.jl"],
    "python": ["python3", "python/test_parse.py"],
    "crystal": ["crystal", "run", "--no-color", "crystal/test_parse.cr", "--"],
    "d": ["d/bin/test_parse"]
}

def test_parsers(input_file_name: str) -> bool:
    success = True
    results = {}
    for lang_name, args in parsers.items():
        print(f"Testing {lang_name}...")
        with Popen([*args, input_file_name], stdout=PIPE, stderr=PIPE, text=True) as proc:
            out, err = proc.communicate()
            results[lang_name] = out
            if err:
                print(f"===== {lang_name} =====\n{err}\n", file=sys.stderr)
                success = False
    for lang_name, output in results.items():
        if output != results["python"]:
            print(f"{lang_name} produced different output than python", file=sys.stderr)
            success = False
    return success


if __name__ == "__main__":
    input_file_name = sys.argv[1]
    raise SystemExit(test_parsers(input_file_name))
