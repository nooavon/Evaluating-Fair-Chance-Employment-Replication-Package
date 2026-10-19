# Extended ACS Replication Package: Ban the Box, 2004–2019

This repo contains the code for Nooa von Schöneman's extension of the ACS
analysis in Anne M. Burton and David N. Wasser's *Revisiting the Unintended
Consequences of Ban the Box*. It reproduces their ACS analysis for 2004–2014
and extends the sample through 2019. The research question, methods, diagnostics,
and results are described in the [bachelor's thesis](../bachelor_von%20Sch%C3%B6neman_Nooa_2026.pdf):
*Evaluating “Fair Chance” Employment: Revisiting Ban the Box's Effect on
Minority Employment with Extended ACS Data* (2026).

This is an independent extension, not a Burton and Wasser-authored release.

## What this package does

The analysis uses annual American Community Survey (ACS) microdata for
2004–2019 to estimate the relationship between Ban the Box (BTB) policies and
employment for U.S.-citizen men aged 25–34 without a bachelor's degree. It
examines non-Hispanic Black, Hispanic, and non-Hispanic White men. The analysis
follows Burton and Wasser's corrected ACS approach and difference-in-differences
design, assigning BTB treatment at the metropolitan statistical area (MSA)
level. The thesis limits the endpoint to 2019 to avoid combining the study
period with the disruption of the COVID-19 pandemic.

The extension's contributions include:

- Extending the ACS observation period from 2004–2014 to 2004–2019 and updating
  the annual BTB law assignment used by the ACS build.
- Re-estimating the 2004–2014 results to document the replication before
  comparing them with estimates from the longer sample.
- Examining event-study pre-trends and sensitivity to the 2008–2009 recession,
  including a 2010–2019 specification for the Hispanic sample.
- Adding checks of whether pre-policy characteristics predict BTB adoption,
  whether treatment is associated with migration, whether estimated effects
  change after 2014, and how estimates evolve as the sample endpoint moves from
  2014 to 2019. The corrected-analysis script also includes Goodman–Bacon
  decompositions.

The thesis reports no robust employment effects across the demographic groups.
Some specifications produce statistically significant estimates. The thesis
discusses these alongside the pre-trend diagnostics and multiple-testing
concerns. See the thesis for the full interpretation.

## Package contents and workflow

The Stata workflow is orchestrated by `master.do`. In order, it:

1. Builds the Doleac and Hansen BTB policy assignment and the annual
   Burton–Wasser-based law assignment.
2. Builds the ACS analysis data.
3. Runs the ACS replication, corrected ACS analysis and diagnostics, additional
   ACS analyses, and ACS summary statistics.

The main scripts are:

| File | Purpose |
| --- | --- |
| `build/dh_replication_btb_policy.do` | Prepares the Doleac and Hansen (2020) BTB policy assignment used for the replication estimates. |
| `build/build_btb_annual_bw.do` | Builds annual BTB law assignments using MSA and principal-city information. |
| `build/build_acs_data.do` | Prepares the ACS data and merges the policy assignments. |
| `analyze/analysis_btb_acs_reproduceDH.do` | Estimates ACS specifications using the Doleac and Hansen policy assignment. |
| `analyze/analysis_btb_acs_correctDH.do` | Runs the corrected ACS estimates, event studies, robustness checks, and extended-sample diagnostics. |
| `analyze/analysis_btb_acs_additional.do` | Runs additional ACS analyses, including public-sector employment, weights, and group-quarters checks. |
| `analyze/summary_stats_acs.do` | Produces ACS sample summary statistics. |

The CPS, ACS–CPS matching, retrospective-design, and mapping scripts from original
Burton and Wasser study are also present in the folder, but their calls are commented out in `master.do`.
They are not part of the documented 2004–2019 ACS run and should not be assumed to
have been extended or validated for this sample period.

Analysis outputs are written under `analyze/out`; logs are written under `analyze/log` and `build/log`.

## Data and provenance

| Data | Expected location | Notes |
| --- | --- | --- |
| IPUMS USA ACS extract, 2004–2019 (`usa_00008.dta`) | `build/build_data` | Required by `build/build_acs_data.do`. The extract definition is documented in `ipums_acs_extract_info.pdf`. Obtain or recreate the extract through [IPUMS USA](https://usa.ipums.org/usa/) and follow its terms of use. |
| Doleac and Hansen BTB data (`BTB_ACS.dta`) | `dh_replication` | Used to reproduce the original policy assignment. See the [Doleac and Hansen replication archive](https://doi.org/10.1086/705880). |
| MSA delineations and crosswalks | `build/build_data` | Includes the 2013 OMB MSA delineation and principal-city files and related crosswalks used by the build scripts. |
| Annual BTB law assignment | Built by `build/build_btb_annual_bw.do` | Based on Burton and Wasser's law-coding work and extended for the analysis period through 2019. The script documents law assignments and sources. |

ACS microdata and third-party law data retain their source terms and
attribution requirements. Their presence in a working copy does not itself
grant permission to redistribute them.

## Requirements and instructions to replicate

- Stata. The package's latest recorded run used Stata/MP 19.5; execution time
  depends on the machine and available memory.
- `config.do` sets package paths and installs the Stata dependencies locally.
  It requires internet access when packages are not already installed.
- The ACS input and other required source files listed above.

To run the ACS workflow:

1. Open `master.do` and set `global base` to the full path to this folder.
2. Ensure the ACS extract and source files are available in the locations
   listed above.
3. Run `master.do` in Stata. If running individual scripts, follow the order
   in `master.do`; later analysis scripts use datasets produced earlier.

## Credit and references

The original research and the 2004–2014 ACS replication approach are due to
Anne M. Burton and David N. Wasser. This extension builds on their replication
package and law-coding work. Please cite their research when using the inherited
code or data. See the [Burton–Wasser replication repository](https://github.com/dwasser/burton-wasser-BTB-JPubE).

- Burton, Anne M., and David N. Wasser (2025). “Revisiting the Unintended
  Consequences of Ban the Box.” *Journal of Public Economics*.
- von Schöneman, Nooa (2026). *Evaluating “Fair Chance” Employment: Revisiting
  Ban the Box's Effect on Minority Employment with Extended ACS Data*. Bachelor's
  thesis.
- Doleac, Jennifer L., and Benjamin Hansen (2020). “The Unintended
  Consequences of ‘Ban the Box’: Statistical Discrimination and Employment
  Outcomes When Criminal Histories Are Hidden.” *Journal of Labor Economics*,
  38, 321–374. https://doi.org/10.1086/705880
- Ruggles, Steven, Sarah Flood, Matthew Sobek, Daniel Backman, Grace Cooper,
  Julia A. Rivera Drew, Stephanie Richards, Renae Rodgers, Jonathan Schroeder,
  and Kari C.W. Williams (2025). *IPUMS USA: Version 16.0* [dataset].
  Minneapolis, MN: IPUMS. https://doi.org/10.18128/D010.V16.0

## License

See [LICENSE](LICENSE) for the code license. Data and other third-party
materials may have separate terms.
