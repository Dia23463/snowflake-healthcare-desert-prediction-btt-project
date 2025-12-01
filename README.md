# snowflake-healthcare-desert-prediction-btt-project
<br><br>
📌 Project Overview
This project aims to identify and support socially vulnerable communities by building an end-to-end pipeline that:
- Classifies census tracts as potential “health deserts” using ML models trained on Snowflake Marketplace datasets
- Generates targeted, actionable public-health recommendations using Snowflake Cortex AI / LLMs.
- Delivers an interactive Streamlit-in-Snowflake application that visualizes vulnerabilities, allows scenario testing, and provides intervention suggestions through a chat-style interface.

The entire project is developed, deployed, and governed inside the Snowflake AI Data Cloud.

🎯 Objectives & Goals
Primary Goals:
- Build a predictive ML classification model for identifying health deserts.
- Integrate a generative AI recommendation engine using built-in LLMs (OpenAI, Anthropic via Snowflake Cortex).
- Create a dynamic, scenario-based Streamlit dashboard for interaction and visualization.
- Store and manage all datasets within Snowflake.
- Deliver full documentation and reproducible notebooks.
Secondary Goals:
- Enhance the SVI data with Marketplace datasets (hospitals, grocery stores, Overture Places, transportation, environmental indicators).
- Ensure the project is modular and extensible for future public-health research.

🧠 Methodology
1. Data Acquisition & Preparation
All datasets are sourced and stored in the Snowflake AI Data Cloud, including:
- CDC Social Vulnerability 
- Index (SVI) dataset 
- IRS ZIP-code–level data 
- Sparksoft Healthcare Data package 
- US population forecast by ZIP codes 
- OVERTURE_MAPS__PLACES
- 
Key tasks:
- Schema design & governance
- Cleaning & STDID (census tract) alignment
- Feature engineering (SVI themes + access metrics + distance scores)

2. Machine Learning Modeling
Using Snowflake ML + Python, we develop a binary classification model:
Inputs (features):
- 15 SVI components
- Healthcare access indicators
- Food access indicators
- Transit accessibility
- Demographic risk indicators
- Environmental indicators
  
Model types tested:
- Logistic Regression
- Random Forest
- XGBoost (final winner)

Evaluation metrics:
- F1-score
- Recall (priority: capturing high-risk areas)
- ROC-AUC

4. Streamlit Application (in Snowflake)
The interactive app includes:
- Dynamic maps & vulnerability visualizations
- Model predictions (Health Desert vs. Non-Health Desert)
- Adjustable input sliders for scenario simulations
- Chat interface for LLM recommendations
- Exportable summaries for policymakers

📊 Results & Key Findings:
- The XGBoost model achieved the highest recall, making it suitable for public-health risk detection.
- Combining SVI + Overture Places data significantly improved model performance.
- LLM-generated recommendations were validated using BLEU/ROUGE and human review.
- The Streamlit UI made it easy for users to test scenarios and explore localized risks.

📈 Visualizations
The Streamlit app includes:
- Choropleth maps of health desert likelihood
- SVI component breakdown
- Infrastructure access heatmaps

🚀 Installation & Setup
1. Clone the Repository
git clone https://github.com/<your-org>/health-desert-risk
cd health-desert-risk

2. Configure Snowflake
Ensure your Snowflake Admin provides:
- Warehouse
- Database
- Schema
- Marketplace dataset access

Update the connection details in:
config/snowflake_connection.yaml

3. Install Dependencies
pip install -r requirements.txt

4. Load Sample Dataset
Run the notebook: notebooks/01_data_load_sample.ipynb
This loads small sample versions of:
- SVI dataset
- Overture Places subset
- Example demographic tables

5. Train the Model
notebooks/02_train_model.ipynb
This notebook covers:
- Feature engineering
- Model selection
- Training + evaluation

Saving the trained model to Snowflake stage

6. Evaluate Model Performance
notebooks/03_evaluate_model.ipynb

Outputs ROC, F1, recall, confusion matrix.

7. Run the Streamlit App (locally or in Snowflake)
Local run: streamlit run app/Main.py
Snowflake deployment: Upload the /app folder to Snowflake stage

Launch via Snowflake Streamlit Apps

📚 Project Documentation

All documentation is available in the /docs directory:

Document	Description
INSTALL.md	Full setup guide
USER_GUIDE.md	How to use the Streamlit application
API_DOCS.md	API schemas, endpoints, LLM prompt templates
DATA_DICTIONARY.md	Dataset descriptions and feature glossary
MODELING_REPORT.md	Modeling decisions & evaluation metrics
ARCHITECTURE.md	System diagram + Snowflake architecture
📂 Repository Structure
├── app/                     # Streamlit application
├── data/                    # Sample datasets
├── docs/                    # Documentation
├── notebooks/               # Jupyter/Colab notebooks
├── models/                  # Saved trained models
├── config/                  # Snowflake + app config files
├── visualizations/          # Screenshots & charts
├── requirements.txt
└── README.md

👥 Individual Contributions
Yodahe
Mehaer
Dia
Gurleen
Rudraksh
Yeabasera

Mentors: Joe Warbington, Tess Dicker

🔮 Potential Next Steps

- Add real-time health resource availability (clinic hours, appointment loads)
- Expand to nationwide predictions
- Add geospatial routing for transportation-based interventions
