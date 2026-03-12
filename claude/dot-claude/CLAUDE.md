# General

- I'm an experienced developer, but I don't always know if I'm asking the right think, nor do I think I'm always correct. Do not immediately agree with me when I attempt to make a correction. CHALLENGE my assumptions if there's something about what I've stated that doesn't sound right instead of blindly obeying commands. If I push back once again, then simply note any objections you may have but proceed with fulfilling the request that was asked of you.
- When writing any code, go easy on comments and documentation. I prefer when code is self-documenting and comments are reserved for tricky code to understand at first glance. Only add documentation to functions/methods, modules, and types when I request it. HOWEVER, do NOT remove any existing code or documentation comments from existing code to adhere to this rule unless the documentation or comment is no longer valid due to the changes being made. You should not try to remove comments and documentation from other places in code to adhere to this rule. IMPORTANT: If you see an existing documentation pattern (e.g., Rust struct fields have documentation comments. You may add documentation comments to any new fields).
- If an open-source library exists that can help do something I am requesting or asking about, please suggest it before attempting a custom solution.
- Never use dashes (em-dashes, en-dashes, or hyphens) as grammatical or syntactical punctuation in code documentation or comments (e.g., "the value is cached - unless the TTL expired"). Hyphens as word joiners in compound words (e.g., "non-blocking", "re-initialize"), in CLI flags (e.g., "--release"), or as bullet items in documentation (e.g., markdown) are fine

# TypeScript / React

- I will almost NEVER use npm as my package manager, so before running any `npm` commands, always look at the root of the web project to see if any package-manager-specific files exist. For example, if you find a `bun.lockb` file, you may infer that the project uses `bun` as the package manager. If this is the case, make sure you use the appropriate variant for the chosen package manager (e.g. instead of using `npx`, use `bunx`), etc.
- Prefer types instead of interfaces.
- Prefer const arrow functions instead of functions for components.
- Avoid default exports unless absolutely necessary.
- For short prop lists, inline the prop type instead of creating a component prop type definition.
- If tailwind is in use anywhere in the codebase, use that and do not use the "style" prop unless it is not possible to obtain the same behavior with tailwind.
- If shadcn is in use anywhere in the codebase, prefer using or reusing any of those components before attempting to remake the component from scratch. If any of those components need to be modified or extended from existing components, you may use composition to create a new component and add it to the same directory as the other shadcn components.
- When creating a large feature that will have lots of related code in different files, particularly if the code or components will only be in use for that feature, create a new directory to group things together.
- If importing icons from lucide-react, prefer the variant that has "Icon" as its suffix.

# Rust

- Always add rust dependencies using `cargo add`, never manually. Avoid specifying a version directly unless there is a specific feature or conflict requiring a pinned version. Once adding them to the project, you may read the `Cargo.toml` file to figure out which versions were installed and adjust your plan from there.
- Avoid working on or fixing any tests until whatever feature is being built has been completed, and offer to fix these only after checking in first, since it's possible we may want to rework the changes, which would necessitate additional test changes.
