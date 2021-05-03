import os


def main(args):
    if os.path.exists(args[1]):
        os.system('$HOME/bin/openf "' + args[1] + '"')
    else:
        os.system('$HOME/bin/openf "' + os.getcwd() + '/' + args[1] + '"')
