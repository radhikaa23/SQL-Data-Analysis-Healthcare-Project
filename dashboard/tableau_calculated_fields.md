# Tableau Calculated Fields

These calculated fields are written in a Tableau-friendly format. Use them if you connect directly to the CSV instead of the MySQL views.

## Admission Date Parsed

```tableau
DATEPARSE("dd-MM-yyyy", [Date of Admission])
```

## Discharge Date Parsed

```tableau
DATEPARSE("dd-MM-yyyy", [Discharge Date])
```

## Length Of Stay

```tableau
DATEDIFF('day', [Admission Date Parsed], [Discharge Date Parsed])
```

## Patient Status

```tableau
IF [Test Results] = "Abnormal" AND [Length Of Stay] >= 15 THEN "High Follow-up Priority"
ELSEIF [Test Results] = "Inconclusive" THEN "Needs More Tests"
ELSEIF [Test Results] = "Normal" AND [Length Of Stay] <= 10 THEN "Likely Stable"
ELSE "Monitor"
END
```

## Age Group

```tableau
IF [Age] < 30 THEN "18-29"
ELSEIF [Age] <= 44 THEN "30-44"
ELSEIF [Age] <= 59 THEN "45-59"
ELSEIF [Age] <= 74 THEN "60-74"
ELSE "75+"
END
```

## Billing Category

```tableau
IF [Billing Amount] >= 35000 THEN "High Bill"
ELSEIF [Billing Amount] >= 20000 THEN "Medium Bill"
ELSE "Low Bill"
END
```

## Admission Quarter

```tableau
"Q" + STR(DATEPART('quarter', [Admission Date Parsed]))
```

## Normal Test Flag

```tableau
IF [Test Results] = "Normal" THEN 1 ELSE 0 END
```

## Abnormal Test Flag

```tableau
IF [Test Results] = "Abnormal" THEN 1 ELSE 0 END
```

## KPI Formulas

- Total Patients: `COUNT([Name])`
- Total Billing: `SUM([Billing Amount])`
- Average Billing: `AVG([Billing Amount])`
- Average Length Of Stay: `AVG([Length Of Stay])`
- Abnormal Tests: `SUM([Abnormal Test Flag])`
