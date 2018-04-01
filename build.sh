#!/bin/bash
set -e

# Loop through each node variant
filename="versions"
while read -ra variants
do
  # set up variables
  node_version="${variants[0]}"
  base_tag="pad39/node-aws:$node_version"
  tags=("${variants[@]:1}")
  echo "processing for node $node_version ..."

  # Generate Docker File
  echo "  generating docker file ..."
  docker_filename="Dockerfile.build.$node_version"
  $(cat Dockerfile.template | sed  -E 's/##NODE_VERSION##/'"$node_version"'/g' > "$docker_filename")

  # Build using docker file
  echo "  building docker image ..."
  docker build -t $base_tag -f $docker_filename .

  # Push to Docker Hub
  for variant in "${variants[@]}"
  do
    tag_v="pad39/node-aws:$variant"
    echo "tagging and pushing for tag: $tag_v"
    docker tag $base_tag $tag_v
    docker push $tag_v
  done
    
done <<< "$(cat versions | sed -E 's/,/ /g')"

# while IFS='' read -r line || [[ -n "$line" ]]; do
#     echo "Text read from file: $line"
# done < "$1"
# read -ra variants <<< "$(cat versions | sed -E 's/,/ /g')"


