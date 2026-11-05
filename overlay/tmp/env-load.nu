# load environment when entering shell
$env.config.hooks.pre_prompt ++= [
    { use bf ; bf env load }
]
