import * as build from "./build.ts";
import * as env from "./env.ts";
import * as fs from "./fs.ts";
import { handle } from "./handle.ts";
import * as sys from "./sys.ts";

/**
 * Output information about the current image including name and version.
 */
export async function image(): Promise<void> {
    // get build values - the second entry contains the distro version, the last the most recent item in the build log
    const $build = Object.entries(await build.get());
    const [$distro, $last] = [$build[1], $build[$build.length - 1]];

    // read image values
    const $etc = env.get("ETC");
    const $image = await fs.read(`${$etc}/IMAGE`);
    const $version = await fs.read(`${$etc}/VERSION`);
    const $built = (await sys.stat(`${$etc}/IMAGE`)).mtim;

    // output image info with a border above and below
    const $border = `\n#${"=".repeat(117)}#\n`;
    console.log($border);
    console.log(await handle(["figlet", "-w", "120", `bfren | ${$image}`], { onSuccess: ($out) => $out.trimEnd() }));
    console.log([
        "\n",
        `bfren/${$image}:${$version}`,
        `[${$distro[0].toLowerCase()}:${$distro[1]}]`,
        `[${$last[0].toLowerCase()}:${$last[1]}]`,
        "\n",
        `Built on ${$built.toUTCString()}`,
        "\n",
        "\n",
        `https://github.com/bfren/docker-${$image}`,
        "\n",
    ].join(" "));
    console.log($border);
}
