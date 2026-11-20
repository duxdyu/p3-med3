"""Export only public MED sources. Does not invoke git or touch existing outputs."""
from pathlib import Path
import argparse,hashlib,json,os,shutil,zipfile

ROOT=Path(__file__).resolve().parents[1]
def source_files():
    roots=["README.md","INSTALL.md","BUILDING.md","CHANGELOG.md","LICENSE",
           "LICENSE-STATUS.md","THIRD_PARTY_NOTICES.md",".gitignore",".gitattributes",
           "MED.groupproj","scripts/build.py","scripts/prepare_dependencies.py",
           "scripts/build_ide.py","scripts/package_runtime.py","scripts/export_source.py","scripts/README.md"]
    files=[ROOT/p for p in roots]
    for directory,extensions in [
        ("src/med",{".pas",".dfm",".dpr",".dproj",".res",".ico"}),
         ("src/shared",{".pas"}),("tests",{".pas",".dfm",".dpr",".dproj",".groupproj",".res",".ico",".md",".py"}),
        ("docs",{".md"}),("dependencies",{".md"})]:
        for p in (ROOT/directory).rglob("*"):
            if any(x in {"__history","__recovery","__pycache__"} for x in p.relative_to(ROOT).parts):continue
            if p.is_file() and p.suffix.lower() in extensions:files.append(p)
    for p in files:
        if not p.is_file() or p.is_symlink():raise RuntimeError(f"Missing or linked source: {p}")
        if os.name=="nt" and p.stat().st_file_attributes&0x400:raise RuntimeError(f"Reparse point: {p}")
    return sorted(set(files),key=lambda p:p.relative_to(ROOT).as_posix())

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--output",type=Path,default=Path("build/github-source"))
    args=ap.parse_args()
    out=args.output.resolve()
    if out==ROOT or ROOT.is_relative_to(out):raise SystemExit("Output may not contain source root")
    archive=out.with_name(out.name+".zip")
    manifest=out.with_name(out.name+".manifest.json")
    for p in [out,archive,manifest]:
        if p.exists():raise SystemExit(f"Refusing to overwrite: {p}")
    files=source_files()
    # Explicit inputs only; no SDK, vendor libraries, logs, or generated binaries.
    rows=[]
    out.mkdir(parents=True)
    for p in files:
        rel=p.relative_to(ROOT);dest=out/rel;dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(p,dest)
        data=dest.read_bytes()
        rows.append({"path":rel.as_posix(),"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest()})
    with zipfile.ZipFile(archive,"x",zipfile.ZIP_DEFLATED) as z:
        for row in rows:z.write(out/row["path"],row["path"])
    manifest.write_text(json.dumps({"files":rows,"archive_sha256":hashlib.sha256(archive.read_bytes()).hexdigest()},
                                  ensure_ascii=False,indent=2),encoding="utf-8")
    print(json.dumps({"files":len(rows),"directory":str(out),"zip":str(archive),"manifest":str(manifest)},ensure_ascii=False))

if __name__=="__main__":main()
