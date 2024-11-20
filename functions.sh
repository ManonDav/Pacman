#!/bin/bash
################################################
#         Projet Bash - Semestre 1 2024        #
# QUESTE Arthur, DAVION Manon, KRZYSKOWIAK Noé #
################################################
source "./affichage.sh"

pacman="C"; vide=" "; bonbon="."; bonus="*"; wall="█"; ghost="@"

up=0; down=0; left=0;right=1
n_up=0; n_down=0; n_left=0; n_right=1

nb_ghosts=3
init_ghost_x=1; init_ghost_y=1
ghosts_x=(); ghosts_y=()
ghosts_current_dir=()
old_cases_values=()

coord_pac_gum=()

score=0
score_max=0
invincibility=0

pacman_x=0; pacman_y=0

coordyTemp=0
laby=()

# Change les nouvelles directions en directions courant.
# Fait par Manon
function change_direc(){
	up=$n_up
	down=$n_down
	left=$n_left
	right=$n_right
}

# Bouge pacman quand la nouvelle direction n'est pas encore valide.
# Fait par Manon
function move(){ 

    #regarde si les nouvelles coordonées de pacman sont correcte si oui il le déplace
	if ((up)); then
		next_y=$((pacman_y - 1))
		if [[ ${laby[$next_y]:$pacman_x:1} != $wall ]]; then
			pacman_y=$next_y
		fi
		if [[ ${laby[$next_y]:$pacman_x:1} == $bonbon ]]; then
			((score+=10))
		elif [[ ${laby[$next_y]:$pacman_x:1} == "$bonus" ]]; then
			invincibility=10
		fi
	elif ((down)); then
		next_y=$((pacman_y + 1))
		if [[ ${laby[$next_y]:$pacman_x:1} != $wall ]]; then
			pacman_y=$next_y
		fi
		if [[ ${laby[$next_y]:$pacman_x:1} == $bonbon ]]; then
			((score+=10))
		elif [[ ${laby[$next_y]:$pacman_x:1} == "$bonus" ]]; then
			invincibility=10
		fi
	elif ((left)); then
		next_x=$((pacman_x - 1))
		if [[ ${laby[$pacman_y]:$next_x:1} != $wall ]]; then
			pacman_x=$next_x
		fi
		if [[ ${laby[$pacman_y]:$next_x:1} == $bonbon ]]; then
			((score+=10))
		elif [[ ${laby[$pacman_y]:$next_x:1} == "$bonus" ]]; then
			invincibility=10
		fi
	elif ((right)); then
		next_x=$((pacman_x + 1))
		if [[ ${laby[$pacman_y]:$next_x:1} != $wall ]]; then
			pacman_x=$next_x
		fi
		if [[ ${laby[$pacman_y]:$next_x:1} == $bonbon ]]; then
			((score+=10))
		elif [[ ${laby[$pacman_y]:$next_x:1} == "$bonus" ]]; then
			invincibility=10
		fi
	fi

	if [[ ${laby[$pacman_y]:$pacman_x:1} = "$ghost" ]]; then
		if [ $invincibility -gt 0 ]; then
			local ghost_num=$(find_ghosts "$pacman_x" "$pacman_y")
			replace_ghost "$ghost_num"
		else
			terminer=0
		fi
	fi

	if [ "$score" -eq "$score_max" ]; then
		terminer=0
	fi

	laby[$pacman_y]="${laby[$pacman_y]:0:$pacman_x}$pacman${laby[$pacman_y]:$((pacman_x + 1))}"
}

# Bouge un fantôme de manière aléatoire. Celui-ci change de direction que s'il rencontre
# un obstacle ou une intersection, sinon il continue son chemin.
# Fait par Arthur
function move_ghost_num() {
	local ghost_num=$1
	local possible_dirs=()
	local opposite_dir

	local old_x=${ghosts_x[$ghost_num]}
	local old_y=${ghosts_y[$ghost_num]}
	local new_x
	local new_y
	
	for ((i = 0; i < 4; i++)); do

		new_x=$old_x
		new_y=$old_y

		case "$i" in
			0)  # up
				((new_y--))
				;;
			1)  # left
				((new_x--))
				;;
			2)  # down
				((new_y++))
				;;
			3)  # right
				((new_x++))
				;;
    	esac

		# 1. Fin du jeu si le fantôme peut toucher le joueur 2. Le fantôme est téléporté
		if [[ ${laby[$new_y]:$new_x:1} = "$pacman" ]]; then
			if [ $invincibility -gt 0 ]; then
				replace_ghost $ghost_num
				return 0
			else
				terminer=0
			fi
		# Sinon ajout de la direction si elle est possible
		elif [[ ${laby[$new_y]:$new_x:1} != "$wall" && ${laby[$new_y]:$new_x:1} != "$ghost" ]]; then
			# Ajout de la direction opposée si elle est possible (sera prise en dernier recours)
			if [[ "$i" == $(( (ghosts_current_dir[$ghost_num] + 2) % 4 )) ]]; then
				opposite_dir=($i)
			else
				possible_dirs+=($i)
			fi
		fi
    done
	# Si aucune direction possible sauf celle oposée alors on l'ajoute
	if [[ ${#possible_dirs[@]} -eq 0 && -n "$opposite_dir" ]]; then
		possible_dirs+=($opposite_dir)
	fi
	# Sélection d'une direction aléatoire si le jeu continue
	if [[ ${#possible_dirs[@]} -gt 0 && $terminer -eq 1 ]]; then
		local new_dir=${possible_dirs[$((RANDOM % ${#possible_dirs[@]}))]}
		new_x=$old_x
		new_y=$old_y

		case "$new_dir" in
			0)  # up
				((new_y--))
				;;
			1)  # left
				((new_x--))
				;;
			2)  # down
				((new_y++))
				;;
			3)  # right
				((new_x++))
				;;
    	esac

		laby[$old_y]="${laby[$old_y]:0:$old_x}${old_cases_values[$ghost_num]}${laby[$old_y]:$(($old_x + 1))}"

		# Enregistrer la valeur de la case et Ajouter le nouveau fantôme
		local tmp_old_case_value="${laby[$new_y]:$new_x:1}"
		if [ "$tmp_old_case_value" == $pacman ]; then
			old_cases_values[$ghost_num]=$vide
		else
			old_cases_values[$ghost_num]="$tmp_old_case_value"
		fi
	
		laby[$new_y]="${laby[$new_y]:0:$new_x}$ghost${laby[$new_y]:$((new_x + 1))}"

		# Mettre à jour les coordonnées du fantôme et la direction courante
		ghosts_x[$ghost_num]=$new_x
		ghosts_y[$ghost_num]=$new_y
		ghosts_current_dir[$ghost_num]=$new_dir
	fi
}


# Bouge pacman en gérant les différentes destinations.
# Fait par Manon
function move_new_coord(){ 

	((invincibility--))
	if [[ $invincibility -lt 0 ]];then
		invincibility=0
	fi

	laby[$pacman_y]="${laby[$pacman_y]:0:$pacman_x}$vide${laby[$pacman_y]:$(($pacman_x + 1))}" # remplace pacman par le vide

    # regarde si les nouvelles coordonées de pacman sont correcte si oui il le déplace

	if ((n_up)); then
		next_y=$((pacman_y - 1))
		if [[ ${laby[$next_y]:$pacman_x:1} != $wall ]]; then
			if [[ ${laby[$next_y]:$pacman_x:1} == "$bonus" ]]; then
				invincibility=10
			elif [[ ${laby[$next_y]:$pacman_x:1} == $bonbon ]]; then
				((score+=10))
			fi
			pacman_y=$next_y
			change_direc

		else 
			move
		fi
		
	elif ((n_down)); then
		next_y=$((pacman_y + 1))
		if [[ ${laby[$next_y]:$pacman_x:1} != $wall ]]; then
			if [[ ${laby[$next_y]:$pacman_x:1} == "$bonus" ]]; then
				invincibility=10
			elif [[ ${laby[$next_y]:$pacman_x:1} == $bonbon ]]; then
				((score+=10))
			fi
			pacman_y=$next_y
			change_direc
		else 
			move
		fi
		
	elif ((n_left)); then
		next_x=$((pacman_x - 1))
		if [[ ${laby[$pacman_y]:$next_x:1} != $wall ]]; then
			if [[ ${laby[$pacman_y]:$next_x:1} == "$bonus" ]]; then
				invincibility=10
			elif [[ ${laby[$pacman_y]:$next_x:1} == $bonbon ]]; then
				((score+=10))
			fi
			pacman_x=$next_x
			change_direc
		else 
			move
		fi
		
	elif ((n_right)); then
		next_x=$((pacman_x + 1))
		if [[ ${laby[$pacman_y]:$next_x:1} != $wall ]]; then
			if [[ ${laby[$pacman_y]:$next_x:1} == "$bonus" ]]; then
				invincibility=10
			elif [[ ${laby[$pacman_y]:$next_x:1} == $bonbon ]]; then
				((score+=10))
			fi
			pacman_x=$next_x
			change_direc
		else 
			move
		fi	
	fi

	if [[ ${laby[$pacman_y]:$pacman_x:1} = "$ghost" ]]; then
		if [ $invincibility -gt 0 ]; then
			local ghost_num=$(find_ghosts "$pacman_x" "$pacman_y")
			replace_ghost "$ghost_num"
		else
			terminer=0
		fi
	fi

	if [ "$score" -eq "$score_max" ]; then
		terminer=0
	fi

	laby[$pacman_y]="${laby[$pacman_y]:0:$pacman_x}$pacman${laby[$pacman_y]:$((pacman_x + 1))}"
}

# Initialise les fantômes. Les fantômes apparaissent de gauche à droite depuis init_ghost_x.
# Fait par Arthur
function init_ghosts() {
    for ((i = 0; i < nb_ghosts; i++)); do
        ghosts_x+=($((init_ghost_x + i)))
        ghosts_y+=($init_ghost_y)

		local ghost_x=${ghosts_x[$i]}
		local ghost_y=${ghosts_y[$i]}
		laby[$ghost_y]="${laby[$ghost_y]:0:$ghost_x}$ghost${laby[$ghost_y]:$((ghost_x + 1))}"

		ghosts_current_dir+=(0)
		old_cases_values+=(" ")
    done
}

# Renvoie l'indice du fantôme se trouvant sur les coordonnées en paramètre
# Fait par Arthur
function find_ghosts() {
    local searched_x=$1
    local searched_y=$2
    local i=0

    for ((; i < nb_ghosts; i++ )); do
        if [[ ${ghosts_x[i]} -eq searched_x && ${ghosts_y[i]} -eq searched_y ]]; then
            echo "$i"
			return 0
        fi
    done
    echo "-1"
}

# Replace au point d'apparition le fantôme donné en paramètre
# Fait par Arthur
function replace_ghost() {
	local ghost_num=$1
	local ghost_x=${ghosts_x[$ghost_num]}
	local ghost_y=${ghosts_y[$ghost_num]}
	
	# On supprime l'ancien fantôme
	laby[$ghost_y]="${laby[$ghost_y]:0:$ghost_x}$vide${laby[$ghost_y]:$(($ghost_x + 1))}"

	ghosts_x[$ghost_num]="$init_ghost_x"
	ghosts_y[$ghost_num]="$init_ghost_y"

	ghost_x=${ghosts_x[$ghost_num]}
	ghost_y=${ghosts_y[$ghost_num]}

	# On afffiche le fantôme à sa nouvelle position
	laby[$ghost_y]="${laby[$ghost_y]:0:$ghost_x}$ghost${laby[$ghost_y]:$(($ghost_x + 1))}"

	# Vérification de l'ancienne valeur de la case et application de cette valeur
	if [[ ${old_cases_values[$ghost_num]} == $bonbon ]]; then
		old_cases_values[$ghost_num]=$vide
		((score+=10))
	elif [[ ${old_cases_values[$ghost_num]} == $bonus ]]; then
		old_cases_values[$ghost_num]=$vide
		invincibility=10
	fi
}

# Fonction pour lire un fichier .txt ajouté par le joueur 1 au max (le premier qu'il trouvera)
# Fait par Manon
function ajout_utilisateur() {
    exclure=('map1.txt' 'map2.txt' 'map3.txt' 'map4.txt')
    lu=false
    for fichier in *.txt; do
        exclu=false
        for exclu_fichier in "${exclure[@]}"; do
            if [[ "$fichier" == "$exclu_fichier" ]]; then
                exclu=true
                break
            fi
        done

        if ! $exclu; then
            file=$fichier
            lu=true
            print_laby2
            lecture_map
			break
        fi
    done
    if ! $lu; then 
	    clear
	    echo -e "\e[0;31m   Il n'y a pas de fichier valide\e[0m"
	    sleep 1
	    print_laby5
	fi
}

# Reset les variables nécessaires pour une nouvelle partie.
# Fait par Manon
function reset(){
	up=0; down=0; left=0; right=1
	n_up=0; n_down=0; n_left=0; n_right=1
	coordyTemp=0;
	score=0;
	score_max=0
	nb_ghosts=3;
	ghosts_x=(); ghosts_y=()
	ghosts_current_dir=(); old_cases_values=()
	init_ghost_x=1; init_ghost_y=1
	pacman_x=0; pacman_y=0
	laby=()
}

# Demande à la l'utilisateur s'il veut rejouer ou non. Relance une partie.
# Fait par manon
function rejouer(){
	clear
	echo -e "
   Votre score est de \e[1;33m$score\e[0m."
	echo -e "   Voulez-vous rejouer [\e[0;32my\e[0m/\e[0;31mn\e[0m] ?"
	read  -rsn1 reponse
	case "$reponse" in
			"y" | "Y")
				reset
				jouer
				;;
			"n" | "N")
				clear
				stty echo # reafficher les entrées
				echo -ne "\e[?25h" # reafficher le curseur
				;;
			*)
				echo -e "   Veillez taper \e[0;32my\e[0m ou \e[0;31mn\e[0m"
				sleep 0.2
				rejouer
				;;
	esac
}