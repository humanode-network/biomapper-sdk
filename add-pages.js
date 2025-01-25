#!/usr/bin/env node
import fs from "node:fs/promises";

process.stdin.removeAllListeners();

const pagesDir = "pages";

const forDisplay = (name) =>
  name.replaceAll(/^[^_]|_./g, (match) => {
    if (match[0] === "_") {
      return ` ${match[1].toUpperCase()}`;
    }
    return match[0].toUpperCase();
  });

const main = async () => {
  const [_context, book] = await new Response(process.stdin).json();

  let files;
  try {
    files = await fs.readdir(pagesDir, { withFileTypes: true });
  } catch (error) {
    if ("code" in error && error.code === "ENOENT") {
      console.log(JSON.stringify(book));
      process.exit(0);
    }
    throw error;
  }

  const pages = [];

  const firstNumber = 2;

  for (const entry of files) {
    if (entry.isDirectory() || entry.isBlockDevice()) {
      continue;
    }

    const extPos = entry.name.lastIndexOf(".md");
    if (extPos < 0) {
      continue;
    }

    const content = await fs.readFile(`${pagesDir}/${entry.name}`, {
      encoding: "utf8",
    });

    const name = forDisplay(entry.name.substring(0, extPos));

    pages.push({
      Chapter: {
        name,
        content,
        number: [firstNumber + pages.length],
        sub_items: [],
        path: entry.name,
        source_path: entry.name,
        parent_names: [],
      },
    });
  }

  book.sections.splice(1, 0, ...pages);

  let number = 1;
  for (const section of book.sections) {
    if ("Chapter" in section) {
      section.Chapter.number = [number++];
    }
  }

  const output = JSON.stringify(book, undefined, "  ");

  if (process.env.BOOK_DEBUG === "true") {
    await fs.writeFile("book-debug.json", output);
  }

  console.log(output);
};

main().then(() => {
  process.exit(0);
});
