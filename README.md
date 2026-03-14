# truth-sets

Curated data files that Senzing uses for demos, testing, and auditing entity resolution (ER) results. Available in JSON/JSONL and CSV formats.

## Repository Structure

```
truthsets/
  demo/          # V4 format (current)
  demo_v3/       # V3 format (legacy)
```

## Data Sources

The truth set includes three data sources that represent common real-world scenarios:

- **Customers** — Your subjects of interest. These could be employees for insider threat detection, vendors for supply chain management, or whatever entities your organization tracks.
- **Watchlist** — Entities you don't want near your organization. These could be entities that have defrauded you in the past or entities you are mandated not to do business with, such as known terrorists and money launderers.
- **Reference** — External data you might purchase about people (demographics, past addresses, contact methods) or companies (firmographics, corporate structure, executives, and ownership).

## File Formats

The V4 demo files use the Senzing FEATURES array format in JSONL (one record per line). CSV versions of each data file are also provided. The V3 demo files use the older flat JSON format.

## Running the Demo

### Prerequisites

Senzing must be installed on a Linux server. See [Explore Senzing Entity Resolution](https://senzing.com/explore-senzing-entity-resolution/) for installation options. If using Docker, run a Senzing tools image with a volume mapped to the directory containing these files.

### Usage

From an initialized Senzing environment, run the demo script:

```bash
./truthset_demo.sh
```

The script performs the following steps:

1. **Purges the database** — Make sure you are OK with this before running!
2. **Loads configuration** — Applies the truth set config (`truthset_config.g2c`)
3. **Loads data** — Loads the customers, watchlist, and reference JSONL files
4. **Takes a snapshot** — Exports matches and calculates reports
5. **Performs an audit** — Compares the snapshot with the alternate truth set key to identify differences
6. **Opens sz_explorer** — An interactive tool for viewing matching statistics and drilling into entity examples, including how records matched or why they did not

## Truth Set Keys

The demo includes two key files that map records to expected entity clusters:

- **`actual_truthset_key.csv`** — The expected correct ER results (ground truth)
- **`alternate_truthset_key.csv`** — Simulated results from a legacy or competing algorithm, used to demonstrate ER auditing

## ER Auditing

An ER audit compares the results of two different systems or algorithms that resolve records to entities. By comparing how each system groups records, you can identify where they agree and where they differ — specifically which records one system merges that the other keeps separate, and vice versa. This highlights the strengths, weaknesses, and philosophical differences between the two approaches.

### Alternate Key Format

The alternate key represents results from a legacy or competing algorithm as a simple CSV:

| Column | Description | Required |
|---|---|---|
| CLUSTER_ID | The entity/cluster identifier assigned by the alternate algorithm | Yes |
| RECORD_ID | The source record identifier | Yes |
| DATA_SOURCE | The data source the record came from | Only if multiple data sources are present |

Records sharing the same `CLUSTER_ID` were merged into the same entity. The `CLUSTER_ID` values do not need to match Senzing's entity IDs — the audit process compares groupings, not IDs.

### Creating an Alternate Key

To generate an alternate key from another ER system, query its results database for the cluster-to-record mapping:

```sql
-- With multiple data sources:
SELECT cluster_id, record_id, data_source
FROM entity_resolution_results
ORDER BY cluster_id, data_source, record_id;

-- With a single data source (DATA_SOURCE column can be omitted):
SELECT cluster_id, record_id
FROM entity_resolution_results
ORDER BY cluster_id, record_id;
```

### About the Demo Alternate Key

The alternate key included here was derived from Senzing's own results and then modified to simulate a legacy or competing algorithm with a different matching philosophy. Two types of changes were made:

**More aggressive name matching** — The alternate algorithm treats close name variants with matching date of birth as definitive matches, even when Senzing considers them only possible matches. For example, "Darla Anderson" and "Darlene Anderson" sharing the same DOB are merged by the alternate algorithm but kept separate by Senzing. This reflects an algorithm that prioritizes recall over precision for name similarity.

**No employer-based matching** — The alternate algorithm does not use employer as a matching feature. Where Senzing merges records based on name + employer (e.g., "Howard Hughes" at "Universal Exports" across REFERENCE and WATCHLIST sources), the alternate algorithm keeps these as separate entities. This is common in algorithms that view employer as too volatile or unreliable to contribute to identity resolution.

### Why Audit?

These are simple examples meant to illustrate the concept. In the real world, an audit like this helps bring algorithmic differences to light, quantify them, and lead to solutions. If the alternate algorithm's results are preferred in certain cases, Senzing can be tuned to match that behavior. Conversely, you may find that the alternate method was too optimistic (merging records that shouldn't be together) or too pessimistic (keeping apart records that clearly belong to the same entity). The good news is that Senzing is tunable — its matching rules, thresholds, and feature usage can all be adjusted to align with your organization's requirements.

## V3 Demo

The `demo_v3` directory contains the V3 format files and multi-stage load scripts (`truthset-load1.sh`, `truthset-load2.sh`, `truthset-load3.sh`) that demonstrate incremental loading and auditing.
