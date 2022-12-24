import os

def main():
    if os.name == "nt":
        print("Not supported on Windows!")
        exit(-1)
    src = ".zshrc"
    dst = "~/.zshrc"
    print(f"Copying '{src}' to '{dst}'!")
    os.system(f"cp {src} {dst}")
    print("Done!")

if __name__ == '__main__':
    main()