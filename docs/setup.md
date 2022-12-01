
# Setting up TDL on your computer
This is a short guide to setting up TDL locally on your development machine.

##  Set up Mira
TDL depends on [Mira](https://github.com/TuftsUniversity/mira_on_hyrax) already existing on your computer because of shared assets.
Go to https://github.com/TuftsUniversity/mira_on_hyrax and follow the steps to set up Mira.

## Get Code:
Clone the code locally. Decide what folder you want the code to be in and run this at that level.
```
git clone https://github.com/TuftsUniversity/tdl_on_hyrax.git
```

## Run preinit script
`./preinit_new_environment.sh`

## Build the Docker Container 
```
docker-compose build
```

## Bring up the Docker Container
```
docker-compose up
```

# Check it out
Go to `http://localhost:4000` to see that tdl is working locally.