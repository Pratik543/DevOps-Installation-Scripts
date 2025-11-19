#!/bin/bash
set -euo pipefail

# =========================================
# Colors and Logging Helpers
# =========================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

log_error() {
    echo -e "${RED}✘ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# =========================================
# Helper: Show System Info
# =========================================
show_system_info() {
    echo "═══════════════════════════════════════════"
    echo "          SYSTEM INFORMATION               "
    echo "═══════════════════════════════════════════"
    
    # OS Info
    echo -e "OS Information:"
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo -e "  Name: $NAME"
        echo -e "  Version: $VERSION_ID"
        echo -e "  ID: $ID"
    else
        echo -e "  OS: $(uname -s)"
        echo -e "  Version: $(uname -r)"
    fi

    # Hardware Info
    echo -e "\nHardware Information:"
    # Using safe reads for CPU info
    local cpu_model
    cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^ *//')
    echo -e "  CPU: ${cpu_model:-Unknown}"
    
    local cpu_cores
    cpu_cores=$(grep -c processor /proc/cpuinfo)
    echo -e "  CPU Cores: $cpu_cores"
    
    local memory_info
    memory_info=$(free -h | grep Mem | awk '{print $2}')
    echo -e "  Memory: ${memory_info:-Unknown}"
    
    local disk_total
    local disk_avail
    disk_total=$(df -h / | awk 'NR==2 {print $2}')
    disk_avail=$(df -h / | awk 'NR==2 {print $4}')
    echo -e "  Disk Space: $disk_total (Total), $disk_avail (Available)"

    # Package Managers
    echo -e "\nAvailable Package Managers:"
    for pm in apt-get yum dnf pacman zypper apk; do
        if command -v "$pm" &> /dev/null; then
            echo -e "  ${GREEN}✓ $pm${NC}"
        else
            echo -e "  ${RED}✗ $pm${NC}"
        fi
    done

    echo "═══════════════════════════════════════════"
    echo ""
}

# =========================================
# Helper: show versions and locations
# =========================================
show_versions() {
  echo
  echo "================ Status Report ================"
  
  echo "--- AWS CLI ---"
  if command -v aws >/dev/null 2>&1; then
    aws --version
    log_success "Location: $(command -v aws)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Docker ---"
  if command -v docker >/dev/null 2>&1; then
    docker --version
    log_success "Location: $(command -v docker)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Lazydocker ---"
  if command -v lazydocker >/dev/null 2>&1; then
    lazydocker --version
    log_success "Location: $(command -v lazydocker)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Java (OpenJDK) ---"
  if command -v java >/dev/null 2>&1; then
    java --version | head -n 1
    log_success "Location: $(command -v java)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Jenkins ---"
  if command -v jenkins >/dev/null 2>&1; then
    jenkins --version
    log_success "Location: $(command -v jenkins)"
  elif systemctl list-units --full -all | grep -Fq "jenkins.service"; then
    log_success "Jenkins Service: Installed (Managed by systemd)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Tomcat ---"
  if [[ -d /usr/local/tomcat ]]; then
    log_success "Tomcat detected at /usr/local/tomcat"
  else
    log_error "Not installed (no /usr/local/tomcat)"
  fi
  echo

  echo "--- Yazi ---"
  if command -v yazi >/dev/null 2>&1; then
    yazi --version
    log_success "Location: $(command -v yazi)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Bat ---"
  if command -v batcat >/dev/null 2>&1; then
    batcat --version
    log_success "Location: $(command -v batcat)"
  elif command -v bat >/dev/null 2>&1; then
    bat --version
    log_success "Location: $(command -v bat)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Croc ---"
  if command -v croc >/dev/null 2>&1; then
    croc --version
    log_success "Location: $(command -v croc)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Btop ---"
  if command -v btop >/dev/null 2>&1; then
    btop --version
    log_success "Location: $(command -v btop)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Fzf ---"
  if command -v fzf >/dev/null 2>&1; then
    fzf --version
    log_success "Location: $(command -v fzf)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Zoxide ---"
  if command -v zoxide >/dev/null 2>&1; then
    zoxide --version
    log_success "Location: $(command -v zoxide)"
  elif [[ -f "$HOME/.local/bin/zoxide" ]]; then
    "$HOME/.local/bin/zoxide" --version
    log_success "Location: $HOME/.local/bin/zoxide"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Atuin ---"
  if command -v atuin >/dev/null 2>&1; then
    atuin --version
    log_success "Location: $(command -v atuin)"
  elif [[ -f "$HOME/.atuin/bin/atuin" ]]; then
    "$HOME/.atuin/bin/atuin" --version
    log_success "Location: $HOME/.atuin/bin/atuin"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Gdu ---"
  if command -v gdu >/dev/null 2>&1; then
    gdu --version
    log_success "Location: $(command -v gdu)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Cargo (Rust) ---"
  if [ -f "$HOME/.cargo/env" ]; then source "$HOME/.cargo/env"; fi
  if command -v cargo >/dev/null 2>&1; then
    cargo --version
    log_success "Location: $(command -v cargo)"
  else
    log_error "Not installed"
  fi
  echo

  echo "--- Nginx ---"
  if command -v nginx >/dev/null 2>&1; then
    # nginx -v prints to stderr, capturing it
    nginx -v 2>&1 | head -n 1
    log_success "Location: $(command -v nginx)"
    
    if systemctl is-active --quiet nginx; then
        log_success "Service: Active (Running)"
    else
        log_info "Service: Inactive"
    fi
  else
    log_error "Not installed"
  fi

  echo "==============================================="
}

# =========================================
# Helper: move a binary into /usr/bin
# =========================================
move_to_usr_bin() {
  local exe="$1"

  if [[ -f "$HOME/$exe" ]]; then
    log_info "Moving $HOME/$exe to /usr/bin/"
    sudo mv "$HOME/$exe" /usr/bin/
    sudo chmod +x "/usr/bin/$exe"
  fi

  if [[ -f "$HOME/.local/bin/$exe" ]]; then
    log_info "Moving $HOME/.local/bin/$exe to /usr/bin/"
    sudo mv "$HOME/.local/bin/$exe" /usr/bin/
    sudo chmod +x "/usr/bin/$exe"
  fi
}

# =========================================
# Execution Start
# =========================================

# Show system info before menu
show_system_info

# =========================================
# Menu
# =========================================
echo "Select tools to install:"
echo " 0) Check installed tools among the following:"
echo " 1) OpenJDK 21"
echo " 2) Jenkins"
echo " 3) Docker"
echo " 4) Lazydocker"
echo " 5) AWS CLI"
echo " 6) Tomcat 11.0.14"
echo " 7) Yazi (Blazing fast terminal file manager.)"
echo " 8) Bat (A cat(1) clone with wings.)"
echo " 9) Croc (Easily and securely send things from one computer to another.)"
echo "10) Btop (A terminal monitor of resources.)"
echo "11) Fzf (A command-line fuzzy finder.)"
echo "12) Zoxide (A smarter cd command. Supports all major shells.)"
echo "13) Atuin (Sync, search and backup shell history.)"
echo "14) Gdu (Pretty fast disk usage analyzer.)"
echo "15) Rust & Cargo 1.85.0 (Systems programming language.)"
echo "16) Nginx (High-performance web server.)"
echo "17) All of the above"
echo

read -rp "Enter choices (e.g., 1 3 5 or 17 for All): " input

# Remove parentheses and commas if user accidentally types them
choices=$(echo "$input" | tr -d '(),')

# If '17' (All) is present, override with full list 1–16
if [[ " $choices " =~ (^|[[:space:]])17([[:space:]]|$) ]]; then
  choices="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
fi

# One apt update early to speed things up
log_info "Updating apt repositories..."
sudo apt update -y

# Flag to track if reboot is needed (Only for Docker)
NEEDS_REBOOT=false

for choice in $choices; do
  case "$choice" in
    0)
      show_versions
      ;;
    1)
      log_info "=== Installing OpenJDK 21 ==="
      sudo apt install -y openjdk-21-jdk
      log_success "OpenJDK 21 installed."
      
      sudo update-alternatives --config java
      # Note: 'vi' is interactive.
      sudo vi /etc/environment

      source /etc/environment
      echo "$JAVA_HOME"
      ;;
      
    2)
     log_info "=== Installing Jenkins ==="
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
      echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
        | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
      sudo apt update -y
      sudo apt install -y jenkins
      sudo systemctl enable jenkins
      sudo systemctl start jenkins
      log_success "Jenkins installed and started."
      ;;

    3)
      log_info "=== Installing Docker Engine ==="
      sudo apt install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc

      sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

      sudo apt update -y
      sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      
      log_info "Adding user $USER to docker group..."
      sudo usermod -aG docker "$USER"
      
      if id "jenkins" &>/dev/null; then
          sudo usermod -aG docker jenkins
      fi
      
      log_success "Docker installed."
      NEEDS_REBOOT=true
      ;;

    4)
      log_info "=== Installing Lazydocker ==="
      LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
        | grep -Po '"tag_name": "v\K[0-9.]+' )
      curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
      mkdir -p lazydocker-temp
      tar xf lazydocker.tar.gz -C lazydocker-temp
      sudo mv lazydocker-temp/lazydocker /usr/bin/
      sudo chmod +x /usr/bin/lazydocker
      rm -rf lazydocker.tar.gz lazydocker-temp
      log_success "Lazydocker installed."
      ;;

    5)
      log_info "=== Installing AWS CLI v2 ==="
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      sudo apt install -y unzip
      unzip -q awscliv2.zip
      sudo ./aws/install -i /usr/local/aws-cli -b /usr/bin --update
      rm -rf awscliv2.zip aws
      log_success "AWS CLI installed."
      ;;

    6)
      log_info "=== Installing Tomcat 11.0.14 ==="
      wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.14/bin/apache-tomcat-11.0.14.tar.gz
      tar -xf apache-tomcat-11.0.14.tar.gz
      rm apache-tomcat-11.0.14.tar.gz
      if [ -d "/usr/local/tomcat" ]; then
          sudo rm -rf /usr/local/tomcat
      fi
      sudo mv apache-tomcat-11.0.14 /usr/local/tomcat
      log_success "Tomcat 11.0.14 installed to /usr/local/tomcat."
      ;;

    7)
      log_info "=== Installing Yazi ==="
      wget -qO yazi.zip https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
      sudo apt install -y unzip
      rm -rf yazi-temp
      mkdir -p yazi-temp
      unzip -q yazi.zip -d yazi-temp
      if compgen -G "yazi-temp/*/yazi" > /dev/null; then
        for f in yazi-temp/*/yazi; do
          sudo mv "$f" /usr/bin/yazi
          break
        done
      fi
      if compgen -G "yazi-temp/*/ya" > /dev/null; then
        for f in yazi-temp/*/ya; do
          sudo mv "$f" /usr/bin/ya
          break
        done
      fi
      sudo chmod +x /usr/bin/yazi || true
      sudo chmod +x /usr/bin/ya || true
      rm -rf yazi.zip yazi-temp
      log_success "Yazi installed."
      ;;

    8)
      log_info "=== Installing Bat (batcat) ==="
      sudo apt install -y bat
      if [[ -x /usr/bin/batcat && ! -e /usr/bin/bat ]]; then
        sudo ln -s /usr/bin/batcat /usr/bin/bat
      fi
      log_success "Bat installed."
      ;;

    9)
      log_info "=== Installing Croc ==="
      curl https://getcroc.schollz.com | bash
      move_to_usr_bin "croc"
      log_success "Croc installed."
      ;;

    10)
      log_info "=== Installing Btop ==="
      sudo apt install -y btop
      log_success "Btop installed."
      ;;

    11)
      log_info "=== Installing Fzf ==="
      sudo apt install -y fzf
      log_success "Fzf installed."
      ;;

    12)
      log_info "=== Installing Zoxide (via Official Script) ==="
      sudo apt install -y curl
      
      curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
      
      # Move to /usr/bin for global access
      move_to_usr_bin "zoxide"
      
      if ! grep -q "zoxide init bash" ~/.bashrc; then
          echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
          log_success "Zoxide added to .bashrc"
      else
          log_info "Zoxide is already configured in .bashrc"
      fi
      ;;

    13)
      log_info "=== Installing Atuin (via Official Script) ==="
      sudo apt install -y curl
      
      curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
      
      # Symlink for global access
      if [[ -f "$HOME/.atuin/bin/atuin" ]]; then
          log_info "Symlinking Atuin to /usr/bin/atuin..."
          sudo ln -sf "$HOME/.atuin/bin/atuin" /usr/bin/atuin
      fi
      
      # --- Configure Config.toml (enter_accept = false) ---
      ATUIN_CONFIG_DIR="$HOME/.config/atuin"
      ATUIN_CONFIG_FILE="$ATUIN_CONFIG_DIR/config.toml"

      mkdir -p "$ATUIN_CONFIG_DIR"

      if [ ! -f "$ATUIN_CONFIG_FILE" ]; then
          # File missing: Create it
          echo "enter_accept = false" > "$ATUIN_CONFIG_FILE"
          log_success "Atuin config created with enter_accept = false"
      else
          # File exists: Check if key exists
          if grep -q "^enter_accept" "$ATUIN_CONFIG_FILE"; then
             # Key exists: Replace true with false
             sed -i 's/^enter_accept *=.*/enter_accept = false/' "$ATUIN_CONFIG_FILE"
          else
             # Key missing: Append it
             echo "enter_accept = false" >> "$ATUIN_CONFIG_FILE"
          fi
          log_success "Atuin config updated (enter_accept = false)"
      fi
      # ----------------------------------------------------

      BASHRC="$HOME/.bashrc"
      
      if [ -f "$BASHRC" ]; then
          if grep -Fq "ATUIN_NOBIND" "$BASHRC"; then
              log_info "Atuin configuration already exists in .bashrc."
          else
              log_info "Adding Custom Atuin configuration to .bashrc..."
              cat << 'EOF' >> "$BASHRC"

# Atuin History
export ATUIN_NOBIND="true"
eval "$(atuin init bash)"

# bind to ctrl-r
bind -x '"\C-r": __atuin_history'

# bind to the up key
bind -x '"\e[A": __atuin_history --shell-up-key-binding'
bind -x '"\eOA": __atuin_history --shell-up-key-binding'
set -o vi # Enable vi mode
EOF
              log_success "Atuin configured in .bashrc"
          fi
      else
          log_error "Warning: .bashrc not found. Skipping configuration."
      fi
      
      log_success "Atuin installed and configured."
      ;;
      
    14)
      log_info "=== Installing Gdu (Disk Usage Analyzer) ==="
      curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
      chmod +x gdu_linux_amd64
      sudo mv gdu_linux_amd64 /usr/local/bin/gdu
      log_success "Gdu installed to /usr/local/bin/gdu"
      ;;

    15)
      log_info "=== Installing Rust & Cargo 1.85.0 ==="
      sudo apt install -y curl

      # 1. Run rustup script (non-interactive via -y)
      curl https://sh.rustup.rs -sSf | sh -s -- -y

      # 2. Source the environment to use cargo/rustup in this script session
      source "$HOME/.cargo/env"

      # 3. Install and set default version 1.85.0
      log_info "Installing Rust version 1.85.0..."
      rustup install 1.85.0
      rustup default 1.85.0
      
      # Verify
      log_success "Rust installed. Current version:"
      cargo --version
      ;;
    
    16)
      log_info "=== Installing Nginx ==="
      sudo apt install -y nginx
      log_info "Enabling and starting Nginx service..."
      sudo systemctl start nginx
      sudo systemctl enable nginx
      log_success "Nginx installed and service enabled."
      ;;

    *)
      log_error "Invalid choice: $choice"
      ;;
  esac
done

source "$HOME/.bashrc"

echo

if [ "$NEEDS_REBOOT" = true ]; then
    log_info "Docker group changes require a system reboot to take effect."
    log_info "System will reboot in 5 seconds..."
    sleep 5
    sudo reboot
else
    log_success "All selected tools installed successfully."
    log_info "No reboot required. Please restart your terminal session to apply .bashrc changes."
fi