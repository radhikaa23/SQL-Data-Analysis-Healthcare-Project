# Tableau Dashboard Plan

## Dashboard Title

Healthcare Admissions and Billing Overview

## Dashboard Goal

Show a simple business view of patient volume, treatment cost, hospital activity, and admission trends. The dashboard should be easy for recruiters to scan and should support filters for deeper exploration.

## Recommended Layout

### Top Row: KPI Cards

- Total Patients
- Total Billing Amount
- Average Billing Amount
- Average Length of Stay
- Abnormal Test Results

### Middle Row: Trends And Conditions

- Monthly Admissions Trend: line chart
- Medical Condition Frequency: horizontal bar chart
- Average Billing by Medical Condition: bar chart

### Bottom Row: Operations View

- Hospital Performance: table or highlight table
- Admission Type Split: donut or stacked bar chart
- Insurance Provider Billing: bar chart

## Filters

- Admission Year
- Medical Condition
- Admission Type
- Insurance Provider
- Gender
- Test Results
- Hospital

## Chart Suggestions

| Section | Chart Type | Purpose |
|---|---|---|
| KPI Cards | Text cards | Quick project summary |
| Monthly Admissions | Line chart | Show patient volume trend over time |
| Disease Frequency | Horizontal bar chart | Show most common conditions |
| Billing by Condition | Bar chart | Compare treatment cost by disease |
| Admission Type | Stacked bar or donut chart | Compare Emergency, Urgent, and Elective admissions |
| Hospital Performance | Highlight table | Compare hospitals by patients, cost, and stay days |
| Insurance Provider | Bar chart | Compare billing and patient count by provider |

## Color Theme

Use a clean healthcare-style palette:

- Deep teal: #0F766E
- Soft blue: #2563EB
- Amber: #F59E0B
- Red for abnormal tests: #DC2626
- Light gray background: #F8FAFC
- Dark text: #1F2937

## Storytelling Flow

1. Start with overall patient and billing KPIs.
2. Show how admissions changed over time.
3. Explain which conditions are most common.
4. Compare costs by condition and insurance provider.
5. Review hospital and doctor activity.
6. End with follow-up priorities based on abnormal and inconclusive test results.

## Tableau Build Steps

1. Connect Tableau to MySQL views or directly to `data/healthcare_dataset.csv`.
2. If using CSV, create calculated fields from `tableau_calculated_fields.md`.
3. Create individual sheets for each chart.
4. Add filters and apply them to all related worksheets.
5. Build a single dashboard with a clean grid layout.
6. Export dashboard image into `screenshots/dashboard_preview.png` after building in Tableau.

## Notes For Portfolio Presentation

- Mention that hospital and doctor analysis is based on available record counts.
- Avoid claiming real medical conclusions because the dataset is synthetic.
- Focus on SQL, dashboarding, and business interpretation skills.
