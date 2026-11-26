library(readr)
df <- read_csv("df.txt")
View(df)

# Dataset dimensions
dim(df)

# Variable names
names(df)

# Data types
str(df)

# Missing values
colSums(is.na(df))

# Number of customers in each treatment group
table(df$segment)

# Basic statistics
summary(df)
#Conversion rate is only 0.9%.

install.packages(c("DBI", "RSQLite", "dplyr", "ggplot2"))

library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

df <- as.data.frame(df)
class(df)

# Create or connect to database
con <- dbConnect(SQLite(), "hillstrom.sqlite")

# Save dataframe to SQLite
DBI::dbWriteTable(
  con,
  "customers",
  df,
  overwrite = TRUE
)

# Verify
dbListTables(con)
dbGetQuery(con, "SELECT COUNT(*) FROM customers")
dbGetQuery(con, "
  SELECT *
  FROM customers
  LIMIT 5
")

dbGetQuery(con, "
SELECT
    segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(spend), 2) AS avg_spending,
    ROUND(AVG(conversion) * 100, 2) AS conversion_in_percent,
    ROUND(AVG(visit) * 100, 2) AS visit_in_percent
FROM customers
GROUP BY segment
")


#Estimating causal effect

# Load data from SQLite
data <- dbReadTable(con, "customers")

# Set No E-Mail as reference group
data$segment <- relevel(
  factor(data$segment),
  ref = "No E-Mail"
)

# Estimate ATE
model <- lm(spend ~ segment, data = data)
summary(model)

# 95% confidence intervals
confint(model)

#So ATE(Men)=0.7698, ATE(Women)=0.4244. Both are significant.
#Whether Mens email has more effect needs further confirmation

# Change reference group
data$segment <- relevel(
  factor(data$segment),
  ref = "Womens E-Mail"
)

# Run regression with women as reference group
model_comparison <- lm(spend ~ segment, data = data)
summary(model_comparison)
#Mens email has statistically bigger effect than womens email

group_stats <- df %>%
  group_by(channel, segment) %>%
  summarise(
    n = n(),
    mean_spend = mean(spend),
    variance = var(spend),
    .groups = "drop"
  )
control <- group_stats %>%
  filter(segment == "No E-Mail") %>%
  select(
    channel,
    control_mean = mean_spend,
    control_n = n,
    control_var = variance
  )
cate_results <- group_stats %>%
  filter(segment != "No E-Mail") %>%
  left_join(control, by = "channel") %>%
  mutate(
    CATE = mean_spend - control_mean,
    
    SE = sqrt(
      variance / n +
        control_var / control_n
    ),
    
    CI_lower = CATE - 1.96 * SE,
    CI_upper = CATE + 1.96 * SE
  )

print(cate_results)
#All CATEs positive

#Does effect differ a lot  by differeent channels?
df$segment <- relevel(
  factor(df$segment),
  ref = "No E-Mail"
)
df$channel <- factor(df$channel)

# Model without treatment interactions
model_base <- lm(
  spend ~ segment + channel,
  data = df
)

# Model with treatment interactions
model_cate <- lm(
  spend ~ segment * channel,
  data = df
)
summary(model_cate)

# Test whether the interactions improve the model
anova(model_base, model_cate)
#No enough evidence to show that effect differs by different channels.

#Does effect differ by spending history?
# Model without interaction
model_base <- lm(
  spend ~ segment + history,
  data = data
)

# Model with interaction
model_interaction <- lm(
  spend ~ segment * history,
  data = data
)

anova(model_base, model_interaction)
#No enough evidence to say that effect differs by spending history.

#How about recency?
model_base <- lm(
  spend ~ segment + recency,
  data = data
)

# Model with interaction
model_interaction <- lm(
  spend ~ segment * recency,
  data = data
)
anova(model_base,model_interaction)
#Still, no enough evidence to say that the effect differs by recency.
