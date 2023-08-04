# This file probably won't work in your machine, all paths are hardcoded
import subprocess
import csv

TIMES = 5

def run_with(lang, n, program="../lox_programs/benchmark.lox"):
    if lang == "rubylox":
        args = ["bundle", "exec", "rubylox", program, str(n)]
    elif lang == "jlox":
        args = ["../../craftinginterpreters/jlox", program, str(n)]

    out = subprocess.run(
        args,
        capture_output = True,
        text = True
    ).stdout.strip('\n')
    return float(out)

def run_multiple(lang, program):
    if lang == "rubylox":
        args = ["bundle", "exec", "rubylox", program]
    elif lang == "jlox":
        args = ["../../craftinginterpreters/jlox", program]

    out = subprocess.run(
        args,
        capture_output = True,
        text = True
    ).stdout.split('\n')
    print(out)
    return float(out[-2])

def meditions_fibonacci():
    with open('meditions.csv', mode='w', newline='') as file:
        writer = csv.writer(file, delimiter=',')
        writer.writerow(("lang", "n", "time"))
        for lang in ["rubylox", "jlox"]:
            for n in range(10, 35):
                for time in range(TIMES):
                    time = run_with(lang, n)
                    writer.writerow((lang, n, time))
                    print((lang, n, time))

def meditions_multiple():
    with open('meditions_multiple.csv', mode='w', newline='') as file:
        writer = csv.writer(file, delimiter=',')
        writer.writerow(("lang", "time"))
        for test in ["binary_trees", "equality", "instantiation", "invocation", "method_call", "properties",
                                 "string_equality", "trees", "zoo_batch", "zoo"]:
            for lang in ["jlox", "rubylox"]:
                    print(f"{lang}-{test}")
                    fname = f"../../craftinginterpreters/test/benchmark/{test}.lox"
                    time = run_multiple(lang, fname)
                    writer.writerow((lang, time))
                    print((lang, time))

if __name__ == "__main__":
    #meditions_fibonacci()
    meditions_multiple()
