# if $HOME/.config/git/user does not exist, create it
if [ ! -f $HOME/.config/git/user ]; then
	cat <<EOF >$HOME/.config/git/user
[user]
  name = John Doe
  email = example@example.com
EOF

	source $HOME/.profile

	COLOR_ORANGE='\033[0;33m'
	COLOR_RESET='\033[0m'
	echo -e "${COLOR_ORANGE}Please edit $HOME/.config/git/user and add your name and email${COLOR_RESET}"
	echo "Press RETURN to continue"
	read
	nvim $HOME/.config/git/user
fi
