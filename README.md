# resume

## To render

```bash
pandoc resume_clean.md \
  --template=resume.latex \
  --lua-filter=job_entry.lua \
  --pdf-engine=xelatex \
  -o resume_mateusiak.pdf
```
