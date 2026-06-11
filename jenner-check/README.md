# Jenner compatibility tests

This directory was added by a pull request from the
[Jenner](https://jenneranalytics.com) project. Each `tNNN_*` subdirectory is a
small SAS bundle derived from code in this repository. The goal is to show that
Jenner — a SAS-compatible engine reachable through an API — runs your tumor
table QC code and produces the same results your SAS installation does.

## What's in here

```
jenner-check/
├── README.md                 # this file
├── run_jenner.sas            # SAS-native runner (PROC HTTP)
├── run_jenner.sh             # mac/linux runner (curl)
├── run_jenner.bat            # Windows runner (curl)
├── t001_ttvariables_spec/          # NAACCR variable spec, summarised
├── t002_missingvars_check/         # variable-presence QC (missing/extra/included)
├── t003_dxyear_dxage/              # diagnosis-year & diagnosis-age distributions
└── t004_macro_version_backcompat/  # the %version v2025 to v1.2 rename macro
    ├── script.sas            # the SAS under test (from this repo)
    ├── autoexec.sas          # options + a small mock CDM input library
    ├── expected.json         # the stable fields Jenner produced
    └── expected/             # human-readable log / listing / artifact links
```

The mock input tables stand in for the site `C:\CDM_folder\` CDM data so each
bundle runs in isolation. Their *contents* are synthetic; the column shapes,
NAACCR field names, formats, and the QC logic itself are yours.

## How to run it

From inside `jenner-check/`, mac/linux:

```bash
./run_jenner.sh --all
```

or from base SAS (9.4 M5+, PROC HTTP):

```sas
%include 'run_jenner.sas';
%jenner_check_all();
```

Each bundle is POSTed to `https://api.jenneranalytics.com/v1/run`; the runner
prints a per-bundle status and a `N pass, N fail` summary. You can also try any
bundle interactively in the hosted workspace at
[jenneranalytics.com](https://jenneranalytics.com).

## Optional: Jenner Compatible badge

```markdown
[![Jenner Compatible](https://jenneranalytics.com/badges/jenner-compatible.svg)](https://jenneranalytics.com)
```

## Don't want future PRs from us?

Reply to this PR with `no-more-prs` (case-insensitive) anywhere in a comment,
or open an issue titled `jenner-check: opt out`, and we'll stop.
