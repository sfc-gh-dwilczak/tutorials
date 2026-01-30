import streamlit as st

# Title of the app
st.title('Simple Streamlit App')

# Input text box
user_input = st.text_input("Enter some text")

# Display the input text
if user_input:
    st.write(f'You entered: {user_input}')