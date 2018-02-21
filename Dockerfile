FROM alpine:3.7

ENV USER alpine
ENV HOME /home/$USER
ENV TERM=xterm-256color

WORKDIR $HOME

# Keepign both curl and git in case they're needed inside the instance
# They take up very little space anyways

RUN addgroup -S $USER && \
    adduser -D -S -h $HOME -s /bin/zsh -G $USER $USER 

RUN apk update && \
   apk upgrade && \
   apk --no-cache add \
     zsh \
     git \
     tzdata \
     shadow \
     tmux \
     neovim \
     mosh-server \
     curl \
     openssh 

COPY build/zshrc $HOME/.zshrc
COPY build/config $HOME/.config
COPY build/init.sh /etc/my_init.d/

RUN apk --no-cache add \
    bash \
    openssl && \
    git clone https://github.com/junegunn/fzf.git $HOME/.config/fzf && \
    echo $USER:$(openssl rand -base64 60) | chpasswd && \
    /bin/bash $HOME/.config/fzf/install && \
    apk del bash openssl 

# Generate ssh keys
RUN /usr/bin/ssh-keygen -A

# Tighten up the ssh setup a little
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
  sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config && \
  echo 'UseDNS no' >> /etc/ssh/sshd_config && \
  echo 'AllowUsers '$USER >> /etc/ssh/sshd_config

RUN chmod +x /etc/my_init.d/*.sh && \
  mkdir -p $HOME/.ssh && \
  chmod -R 700 $HOME/.ssh

# Makes the terminal come alive with colors
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.config/zsh/zsh-syntax-highlighting

#      ssh mosh
EXPOSE 22 60001/udp

CMD ["/etc/my_init.d/init.sh"]
