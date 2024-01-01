import streamlit as st
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.graph_objects as go
from prophet import Prophet
from prophet.plot import plot_plotly


class Graphs:
    # Plot Time vs. Price Data.
    def plot_price_data(data):
        fig = go.Figure(
            [
                go.Scatter(
                    x=data["Month"],
                    y=data["Average Price HRC Exy Mumbai India 2.5-8mm, IS2062 Rs"],
                )
            ]
        )
        fig.update_xaxes(title_text="Month")
        fig.update_yaxes(title_text="Average Price HRC Exy Mumbai")
        fig.layout.update(
            title_text="Time Series Price Plot with RangeSlider.",
            xaxis_rangeslider_visible=True,
        )
        st.plotly_chart(fig)

    # Plot Time vs. Country Data.
    def plot_country_data(data):
        fig = go.Figure()
        fig.add_trace(
            go.Scatter(
                x=data["Month"],
                y=data["Peak Down CFR India"],
                name="Peak Down CFR India",
            )
        )
        fig.add_trace(
            go.Scatter(
                x=data["Month"],
                y=data["Low Vol PCI CFR India"],
                name="Low Vol PCI CFR India",
            )
        )
        fig.add_trace(
            go.Scatter(
                x=data["Month"],
                y=data["Semi Soft CFR India"],
                name="Semi Soft CFR India",
            )
        )
        fig.layout.update(
            title_text="Time Series Country Plot with RangeSlider.",
            xaxis_rangeslider_visible=True,
        )
        st.plotly_chart(fig)

    # Plot Pearson Correlation Matrix.
    def plot_correlation_matrix(data):
        fig, ax = plt.subplots(figsize=(24, 18))
        plt.suptitle("Correlation Matrix.", fontsize=40, fontweight="demi")
        sns.heatmap(data.corr(), annot=True, cmap=plt.cm.CMRmap_r, ax=ax)
        st.write(fig)


st.title("Price Prediction Dashboard")


@st.cache_data
def load_data():
    data = pd.read_excel("dataset\price-summary.xlsx").drop("Unnamed: 0", axis=1)
    data = data.dropna(subset="Average Price HRC Exy Mumbai India 2.5-8mm, IS2062 Rs")
    data.reset_index(drop=True, inplace=True)
    return data


data = load_data()

st.subheader("Raw Dataset.")
st.write(data.tail(20))

st.subheader("Data Visualization.")
Graphs.plot_price_data(data)
Graphs.plot_country_data(data)
Graphs.plot_correlation_matrix(data)

st.subheader("Forecasting.")
n_month = st.slider("Month of Prediction:", 1, 3)

# Forecast Price with Prophet.
df_train = data[["Month", "Average Price HRC Exy Mumbai India 2.5-8mm, IS2062 Rs"]]
df_train["cap"] = 65000
df_train = df_train.rename(
    columns={
        "Month": "ds",
        "Average Price HRC Exy Mumbai India 2.5-8mm, IS2062 Rs": "y",
    }
)

m = Prophet(growth="logistic", changepoint_prior_scale=0.031)
m.fit(df_train)
future = m.make_future_dataframe(periods=n_month * 30)
future["cap"] = 65000
forecast = m.predict(future)

forecast["yhat_average"] = forecast[["yhat", "yhat_upper"]].mean(axis=1)

# Show and Plot Forecast.
st.markdown("Forecasted Price for Upcoming Months.")
st.write(forecast[["ds", "yhat", "yhat_average", "yhat_upper", "yhat_lower"]].tail(60))

st.markdown(f"Forecast Plot for {n_month} month.")
fig = plot_plotly(m, forecast)
st.plotly_chart(fig, theme="streamlit")
