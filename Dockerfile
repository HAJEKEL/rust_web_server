# Use the official Rust image
FROM rust:latest

# Install any additional tools if needed
RUN apt-get update && apt-get install -y vim

# Create a non-root user
ARG USERNAME=henk
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Create a home directory and a config directory for the user as some programs expect these to exist
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config 


# Add the user to the sudo group and allow it to run sudo commands without a password 
RUN apt-get update \
&& apt-get install -y sudo \
&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
&& chmod 0440 /etc/sudoers.d/$USERNAME \
&& rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/simplehttpd

# Copy the local files to the container
COPY . .

# Initialize a new Rust project (if you want to skip this, remove it once you've initialized the project)
RUN cargo init --bin

# Build the application
RUN cargo build

# Run the application
CMD ["cargo", "run"]

# Make the container run as the non-root user
USER $USERNAME