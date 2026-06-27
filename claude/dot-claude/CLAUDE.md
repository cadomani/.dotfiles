# General

- I'm an experienced developer, but I don't always know if I'm asking the right think, nor do I think I'm always correct. Do not immediately agree with me when I attempt to make a correction. CHALLENGE my assumptions if there's something about what I've stated that doesn't sound right instead of blindly obeying commands. If I push back once again, then simply note any objections you may have but proceed with fulfilling the request that was asked of you.
- Do not remove existing comments unless the code associated with them is changing or being removed.
- If an open-source library exists that can help do something I am requesting, please suggest it before attempting a custom solution.
- If you add empty new lines for spacing, those should be free from any whitespace characters.
- Never say "You're absolutely right"
- If I challenge you on a suggestion, don't assume I'm correct immediately. Let me know if you will need to confirm my rebuttal and after you've checked if I'm actually correct, then proceed with next steps.
- When writing any code, go easy on comments and documentation. I prefer when code is self-documenting and comments are reserved for tricky code to understand at first glance. Only add documentation to functions/methods, modules, and types when I request it. HOWEVER, do NOT remove any existing code or documentation comments from existing code to adhere to this rule unless the documentation or comment is no longer valid due to the changes being made. You should not try to remove comments and documentation from other places in code to adhere to this rule. IMPORTANT: If you see an existing documentation pattern (e.g., Rust struct fields have documentation comments. You may add documentation comments to any new fields).

# TypeScript / React

- I will almost NEVER use npm as my package manager. If you will install a new package, assume I am either using `pnpm` or `bun` and you may check this by looking for specific files related to those package managers. You should only use `npm` for non-destructive operations that do not touch the `node_modules` directory or `package-lock.json` file.
- Before running any `npm` commands, always look at the root of the web project to see if any package-manager-specific files exist. For example, if you find a `bun.lockb` file, you may infer that the project uses `Bun` as the package manager. If this is the case, make sure you use the appropriate variant for the chosen package manager (e.g. npx -> bunx), etc.
- Prefer types instead of interfaces.
- Prefer const arrow functions instead of functions for components.
- Avoid default exports unless absolutely necessary.
- For short prop lists, inline the prop type instead of creating a component prop type definition.
- If tailwind is in use anywhere in the codebase, use that and do not use the "style" prop unless it is not possible to obtain the same behavior with tailwind.
- If shadcn is in use anywhere in the codebase, prefer using or reusing any of those components before attempting to remake the component from scratch. If any of those components need to be modified or extended from existing components, you may use composition to create a new component and add it to the same directory as the other shadcn components.
- When creating a large feature that will have lots of related code in different files, particularly if the code or components will only be in use for that feature, create a new directory to group things together.
- If importing icons from lucide-react, prefer the variant that has "Icon" as its suffix.
- Always attempt to get my IDE's diagnostics when wrapping up a list of changes. Sometimes they are more strict than the linter rules elsewhere.

# Rust

- Always add rust dependencies using `cargo add`, never manually. Avoid specifying a version directly unless there is a specific feature or conflict requiring a pinned version. Once adding them to the project, you may read the `Cargo.toml` file to figure out which versions were installed and adjust your plan from there.

# Code Reading Instructions

When reading Rust files, ignore (don't read) any code within `#[cfg(test)]` modules unless I explicitly ask about tests. These sections are marked as:

```rust
#[cfg(test)]
mod tests {
    // ... test code ...
}
```

Focus only on the production code outside these test modules. This is done to save tokens on extremely large files. If you must, first grep to find where this section is and simply read the lines before that. The tests will always be at the end of the code and you can safely assume they will not be interspersed through the file.
