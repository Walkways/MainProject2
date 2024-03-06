# Utilisation de l'image officielle de Python (choisissez la version appropriée)
FROM python:2.7

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

#ARG BDD_IP=""
#ARG BDD_MDP=""
# Définir une variable d'environnement
#ENV BDD_IP=${BDD_IP}
#ENV BDD_MDP=${BDD_MDP}


# Copier les fichiers de l'hôte vers le répertoire de travail dans le conteneur
COPY /app /app


# Installation des dépendances à partir du fichier requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

# Lancement de l'application lors du démarrage du conteneur
CMD [ "python", "app.py" ]