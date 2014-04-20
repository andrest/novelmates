# Novelmates

Novelmates is a social platform for book meet-ups. Instead of joining a periodical book club, attend the events for the titles you have already read and want to discuss.



## Project Setup & Deploying

The application can be downloaded from its GitHub hosted repository. This step can be skipped if the included source code bundle is used. GitHub repository can be downloaded with the following command:


    git clone https://github.com/andrest/novelmates.git


The suggested option for deploying the application is Heroku. If Heroku can not be used any other hosting provider that provides Ruby and MongoDB can be used, the configuration for this will not be provided. The source code includes Heroku configuration in \emph{Procfile} and this makes deploying a straightforward process.

If the Heroku toolbelt is installed the application can be deployed from the shell:

    cd novelmates
    heroku create
    git push heroku master

This changes the working directory to that of the repository cloned, creates a new Heroku application and pushes to code to Heroku repository. For data storage a MongoDB provider has to be chosen. Any provider is fine however I suggest MongoSoup, this is also used by the production server.