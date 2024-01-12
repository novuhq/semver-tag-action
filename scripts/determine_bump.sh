#!/bin/bash
version=$1
labels=$(cat $2)

prerelease_suffix=$(echo $version | awk -F- '{print $2}' | awk -F. '{print $1}')
echo "prerelease_suffix $prerelease_suffix"

if [[ $labels == *"bump:major"* ]] && [[ $labels == *"pre:demo"* ]]; then
  bump_type="major_demo"
elif [[ $labels == *"bump:major"* ]] && [[ $labels == *"pre:beta"* ]]; then
  bump_type="major_beta"
elif [[ $labels == *"bump:major"* ]] && [[ $labels == *"pre:alpha"* ]]; then
  bump_type="major_alpha"
elif [[ $labels == *"bump:minor"* ]] && [[ $labels == *"pre:demo"* ]]; then
  bump_type="minor_demo"
elif [[ $labels == *"bump:minor"* ]] && [[ $labels == *"pre:beta"* ]]; then
  bump_type="minor_beta"
elif [[ $labels == *"bump:minor"* ]] && [[ $labels == *"pre:alpha"* ]]; then
  bump_type="minor_alpha"
elif [[ $labels == *"bump:patch"* ]] && [[ $labels == *"pre:demo"* ]]; then
  bump_type="patch_demo"
elif [[ $labels == *"bump:patch"* ]] && [[ $labels == *"pre:beta"* ]]; then
  bump_type="patch_beta"
elif [[ $labels == *"bump:patch"* ]] && [[ $labels == *"pre:alpha"* ]]; then
  bump_type="patch_alpha"
elif [[ $labels == *"bump:major"* ]]; then
  bump_type="major"
elif [[ $labels == *"bump:minor"* ]]; then
  bump_type="minor"
elif [[ $labels == *"bump:patch"* ]]; then
  bump_type="patch"
elif [[ $labels == *"bump:release"* ]]; then
  bump_type="release"
elif [[ $labels == *"pre:demo"* ]] && [[ -z $prerelease_suffix ]]; then
  bump_type="demo"
elif [[ $labels == *"pre:beta"* ]] && [[ -z $prerelease_suffix ]]; then
  bump_type="beta"
elif [[ $labels == *"pre:alpha"* ]] && [[ -z $prerelease_suffix ]]; then
  bump_type="alpha"
elif [[ $labels == *"pre:demo"* ]] && [[ -n $prerelease_suffix ]]; then
  bump_type="demo_prerelease_suffix"
elif [[ $labels == *"pre:beta"* ]] && [[ -n $prerelease_suffix ]]; then
  bump_type="beta_prerelease_suffix"
elif [[ $labels == *"pre:alpha"* ]] && [[ -n $prerelease_suffix ]]; then
  bump_type="alpha_prerelease_suffix"
elif [[ $labels != *"pre:"* ]] && [[ $labels != *"bump:"* ]] && [[ -z $prerelease_suffix ]]; then
  bump_type="without_labels_prerelease_suffix"
elif [[ $labels != *"pre:"* ]] && [[ $labels != *"bump:"* ]]; then
  bump_type="without_labels"
else
  echo "No version bump labels found. Bumping build number."
  bump_type="build"
fi

echo $bump_type

generate_semver_command() {
  case $bump_type in
  "release")
    if [[ -z $prerelease_suffix ]]; then
      echo "semver bump patch $version"
    else
      echo "semver bump release $version"
    fi
    ;;
  "major_demo")
    first_major_demo=$(semver bump major $version)
    echo "semver bump prerel demo $first_major_demo"
    ;;
  "major_beta")
    first_major_beta=$(semver bump major $version)
    echo "semver bump prerel beta $first_major_beta"
    ;;
  "major_alpha")
    first_major_alpha=$(semver bump major $version)
    echo "semver bump prerel alpha $first_major_alpha"
    ;;
  "minor_demo")
    first_minor_demo=$(semver bump minor $version)
    echo "semver bump prerel demo $first_minor_demo"
    ;;
  "minor_beta")
    first_minor_beta=$(semver bump minor $version)
    echo "semver bump prerel beta $first_minor_beta"
    ;;
  "minor_alpha")
    first_minor_alpha=$(semver bump minor $version)
    echo "semver bump prerel alpha $first_minor_alpha"
    ;;
  "patch_demo")
    first_patch_demo=$(semver bump patch $version)
    echo "semver bump prerel demo $first_patch_demo"
    ;;
  "patch_beta")
    first_patch_beta=$(semver bump patch $version)
    echo "semver bump prerel beta $first_patch_beta"
    ;;
  "patch_alpha")
    first_patch_alpha=$(semver bump patch $version)
    echo "semver bump prerel alpha $first_patch_alpha"
    ;;
  "major")
    echo "semver bump major $version"
    ;;
  "minor")
    echo "semver bump minor $version"
    ;;
  "patch")
    echo "semver bump patch $version"
    ;;
  "demo")
    first_demo=$(semver bump patch $version)
    echo "semver bump prerel demo $first_demo"
    ;;
  "beta")
    first_beta=$(semver bump patch $version)
    echo "semver bump prerel beta $first_beta"
    ;;
  "alpha")
    first_alpha=$(semver bump patch $version)
    echo "semver bump prerel alpha $first_alpha"
    ;;
  "demo_prerelease_suffix")
    if [[ $prerelease_suffix == *"beta"* ]] || [[ $prerelease_suffix == *"alpha"* ]]; then
      echo "semver bump prerel demo $version"
    elif [[ $prerelease_suffix == *"demo"* ]]; then
      echo "semver bump prerel $version"
    fi
    ;;
  "beta_prerelease_suffix")
    if [[ $prerelease_suffix == *"beta"* ]] || [[ $prerelease_suffix == *"demo"* ]]; then
      echo "semver bump prerel $version"
    else
      echo "semver bump prerel beta $version"
    fi
    ;;
  "alpha_prerelease_suffix")
    if [[ $prerelease_suffix == *"alpha"* ]] || [[ $prerelease_suffix == *"demo"* ]] || [[ $prerelease_suffix == *"beta"* ]]; then
      echo "semver bump prerel $version"
    else
      echo "semver bump prerel alpha $version"
    fi
    ;;
  "without_labels")
    echo "semver bump prerel $version"
    ;;
  "without_labels_prerelease_suffix")
    first_without_labels_prerelease_suffix=$(semver bump patch $version)
    echo "semver bump prerel alpha $first_without_labels_prerelease_suffix"
    ;;
  *)
    echo "Invalid bump type"
    exit 1
    ;;
  esac
}
# Function to extract the prerelease label from the version
get_prerelease_label() {
  echo "$1" | awk -F- '{print $2}' | awk -F. '{print $1}'
}

# Generate and execute the first semver command
first_command=$(generate_semver_command "$labels" "$version")
new_version=v$(eval "$first_command")
echo "sha=$(git rev-parse HEAD)"
echo "sha_short=$(git rev-parse --short HEAD)"
echo "Current Version: $version"
echo "Labels attached to the Pull Request: $labels"
echo "New Version: $new_version"

echo "sha=$(git rev-parse HEAD)" >> $GITHUB_OUTPUT
echo "sha_short=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
echo "new_version=$new_version" >> $GITHUB_OUTPUT
echo "current_version=$version" >> $GITHUB_OUTPUT
