## Contributions
- Arthur QUESTE https://github.com/arthurqst
- Manon DAVION https://github.com/ManonDav
- Noé KRZYSKOWIAK https://github.com/Salapille

# Pac-Man en Bash

Bienvenue dans **Pac-Man en Bash**, une implémentation simple du célèbre jeu d'arcade, réalisée entièrement en Bash. Ce projet met en œuvre un labyrinthe, des fantômes poursuivant Pac-Man, et la gestion des déplacements du joueur dans un environnement de terminal.

## Sommaire
- [À propos du projet](#à-propos-du-projet)
- [Fonctionnalités](#fonctionnalités)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Règles du jeu](#règles-du-jeu)
- [Ajouter sa carte](#map-creation)

## À propos du projet
Ce projet est un jeu Pac-Man simplifié développé en Bash pour explorer la programmation de jeux dans un environnement de terminal. Il s'agit d'une version minimaliste du jeu, où le joueur contrôle Pac-Man pour échapper aux fantômes et récupérer les pastilles.

## Fonctionnalités
- Déplacements de Pac-Man contrôlés par l'utilisateur.
- Fantômes contrôlés par l'ordinateur avec des comportements aléatoires ou semi-dirigés.
- Système de labyrinthe représenté par un tableau de chaînes de caractères.
- Détection de collision et gestion de l'état du jeu (victoire, défaite).
- Interface textuelle simple en mode terminal.

## Prérequis
- Un système d'exploitation basé sur Unix, tel qu'Ubuntu.
- Un terminal supportant Bash.
- Bash version 4.0 ou supérieure.

## Installation
1. Clonez le dépôt du projet :
   ```bash
   git clone https://github.com/arthurqst/PacmanGame-BashProject
2. Donner le droit d'exécution à main.sh :
   ```bash
   chmod -x ./main.sh
3. Lancer main.sh :
   ```bash
   ./main.sh
  
## Utilisation
- Flèches directionnelles pour le déplacement.
- Autres intéractions utilisateur indiqués dans le programme

## Règles du jeu
- Condition gagnante : Ramasser toutes les pastilles.
- Condition perdante : Toucher un fantôme.
- Les bonus (symbole *): offrent une invincibilité durant un court instant

## Map creation
- Le symbole '|' est utilisé pour représenter les différents mur de la carte.
- La carte doit être fermée pour éviter tout bug.
- Le symbole '.' représente le pac-gum il faut tous les ramasser pour compléter un niveau.
- Il faut s'assurer que tous les pac-gum soient accessible sinon le niveau ne pourra pas être terminé.
- Le symbole * représente un super pac-gum qui rend temporairement invincible pacman et lui permet de manger les fantômes.
- Le symbole C représente Pacman et son point d'apparition faites attention à ce que le point d'apparition permette d'accéder à la carte.
- Le symbole A représente le point d'apparition du fantôme prévoyer de l'espace sur la droite pour l'apparition des autres fantômes.
- Le fichier doit être un fichier texte avec l'extension '.txt' et doit se trouver dans le fichier avec les autres cartes
Attention ! Notre programme ne lit que le premier fichier .txt qu'il trouve dans le dossier courant.
