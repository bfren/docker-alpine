# load environment when entering shell
$env.config = ($env.config | upsert hooks {
    pre_prompt: { ^bf-withenv env | lines | parse "{key}={val}" | transpose -i -r -d | load-env $in }
})
