# Verify Git signatures

This GitHub Action is meant to be triggered on new tags being pushed to remote.  
It attempts to verify that the signature on the tag that was pushed was created 
by of the usernames specified in the action's configuration.

## Inputs

### `allowed-release-signers`

**Required** A comma separated list of GitHub usernames who are allowed to add 
and push release tags.  

## Outputs

### `signed_by`

The username who signed the tag, if any.

## Example usage

```yaml
uses: actions/check-signature-action@v1
env:
  GH_TOKEN: ${{ github.token }}
with:
  allowed-release-signers: yoavamit,ddz
```
