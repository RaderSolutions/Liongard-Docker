# Liongard-Docker
Docker Container for Liongard ROAR Linux Agent

Installation: 
`curl -o setup.sh https://raw.githubusercontent.com/RaderSolutions/Liongard-Docker/main/setup.sh && chmod a+x ./setup.sh && ./setup.sh <INSTANCE> "<SERVICE_PROVIDER>" <ACCESS_KEY> <ACCESS_SECRET> "<ENVIRONMENT>"`


            INSTANCE = Your Liongard instance. You only need to include the first part of the subdomain, "app.liongard.com" is assumed
            SERVICE_PROVIDER = The name of your company as it appears in the top left corner of your Liongard instance
            ACCESS_KEY = Your Access Key from Liongard
            ACCESS_SECRET = Your Access Secret from Liongard
            ENVIRONMENT = The name of the Environment in Liongard to associate the Agent to
            Quotes around spaced names are required.
