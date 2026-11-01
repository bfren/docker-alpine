import * as fs from "./fs.ts";
import { handle } from "./handle.ts";
import * as write from "./write.ts";

/**
 * Generate output using input as an esh template.
 *
 * @param input Input file.
 * @param output Output file - if omitted the output will be returned instead of saved.
 * @returns The generated output, or the output file if it was saved.
 */
export async function esh(input: string, output?: string): Promise<string> {
    write.debug("esh", "Parsing esh template %s.", input);

    // ensure template file exists
    if (await fs.isNotFile(input)) write.error("esh", "Template %s does not exist.", input);

    // print esh's error output and write error message
    const $onFailure = ($code: number, $err: string): never => {
        console.error($err.trimEnd());
        write.error("esh", "Error %d parsing template %s.", $code, input);
    };

    // generate template - and return value if output is not set, or save to file and return filename
    if (!output) return await handle(["esh", input], { script: "esh", onFailure: $onFailure }) ?? "";

    await handle(["esh", "-o", output, input], { script: "esh", ignoreSuccess: true, onFailure: $onFailure });
    write.debug("esh", " .. output saved to %s.", output);
    return output;
}
