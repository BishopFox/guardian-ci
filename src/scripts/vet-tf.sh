terraform fmt --check . || (echo "Terraform is not formatted correctly. Please run 'terraform fmt'" && exit 1)

latest_module_version="v$(cat ~/terraform-modules/VERSION)"

tf_versions=$(grep -E 'source\s+=\s+.*bishopfox.*v[0-9\.]*' ./*.tf | grep -oE 'v[0-9\.]+')

if [[ -n $tf_versions ]]; then
  echo "$tf_versions" | while read -r version; do
    if [[ "$latest_module_version" != "$version" ]]; then
      echo "terraform modules can be upgraded from $version to $latest_module_version"
      echo "if it cannot be upgraded, remove this job from the pipeline and re-add it when modules can be upgraded"

      exit 1
    fi
  done
fi
