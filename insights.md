# Healthcare Data Analysis Insights

## Dataset Summary

- Total records: 10,000
- Admission date range: 2018-10-30 to 2023-10-30
- Average patient age: 51.5 years
- Age range: 18 to 85 years
- Average billing amount: 25,516.81
- Total billing amount: 255,168,067.78

## Patient Trends

- The dataset includes adult patients from young adults to senior citizens.
- Age-group analysis helps compare patient volume and billing across life stages.
- Patient volume is useful for trend analysis, but the dataset should not be treated as real medical evidence because it is synthetic.

## Disease Frequency Analysis

| Medical Condition | Patient Count |
|---|---:|
| Asthma | 1,708 |
| Cancer | 1,703 |
| Hypertension | 1,688 |
| Arthritis | 1,650 |
| Obesity | 1,628 |
| Diabetes | 1,623 |

Asthma and Cancer have the highest patient counts. The condition distribution is fairly balanced, which makes comparisons easier.

## Treatment Cost Analysis

| Medical Condition | Average Billing Amount |
|---|---:|
| Diabetes | 26,060.12 |
| Obesity | 25,720.84 |
| Cancer | 25,539.10 |
| Asthma | 25,416.87 |
| Hypertension | 25,198.03 |
| Arthritis | 25,187.63 |

Diabetes has the highest average billing amount, making it a useful focus area for cost analysis.

## Admission And Discharge Trends

- Urgent admissions: 3,391
- Emergency admissions: 3,367
- Elective admissions: 3,242
- Average length of stay is around 15 to 16 days across conditions.
- Arthritis has the highest average length of stay at 15.99 days.
- The busiest month in the dataset is 2022-10 with 207 admissions.
- The busiest quarter is 2020-Q2 with 542 admissions.

## Insurance Provider Analysis

| Insurance Provider | Patient Count |
|---|---:|
| Cigna | 2,040 |
| Blue Cross | 2,032 |
| Aetna | 2,025 |
| UnitedHealthcare | 1,978 |
| Medicare | 1,925 |

Cigna has the highest patient count, followed closely by Blue Cross and Aetna.

## Hospital Performance

- Hospital names are highly distributed, with many hospitals having small counts.
- Smith PLC has the highest patient count with 19 records.
- For fair dashboard comparison, hospital metrics should filter to hospitals with at least 10 patients.
- Useful hospital KPIs include patient count, average stay days, average billing amount, and normal test result percentage.

## Doctor Performance

- Doctor names are widely distributed.
- Michael Johnson has the highest patient count with 7 records.
- Doctor analysis should be presented as workload/activity analysis, not actual clinical quality scoring.

## Test Result Insights

- Abnormal results: 3,456
- Inconclusive results: 3,277
- Normal results: 3,267

Abnormal test results are the largest category, so follow-up planning is an important dashboard theme.

## Top Insights

1. Asthma is the most frequent condition in the dataset.
2. Diabetes has the highest average billing amount.
3. Arthritis has the longest average stay.
4. Urgent admissions are slightly more common than Emergency and Elective admissions.
5. Cigna has the highest patient count among insurance providers.
6. Abnormal test results are more common than Normal and Inconclusive results.
7. Monthly trends show visible changes in admission volume over time.

## Business Recommendations

- Track high-cost conditions like Diabetes separately to improve cost planning.
- Use admission trends to plan staffing during high-volume months and quarters.
- Monitor patients with Abnormal or Inconclusive test results for follow-up scheduling.
- Compare hospitals using patient count and average stay together, not patient count alone.
- Use insurance provider trends to understand billing concentration and coverage patterns.
- Build dashboard filters for condition, hospital, and admission type so stakeholders can explore the data easily.
