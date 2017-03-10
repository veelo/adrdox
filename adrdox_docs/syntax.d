// just docs: adrdox syntax
/++
This document describes the syntax recognized by my documentation generator. It uses a hybrid of ddoc and markdown syntax, with some customizations and pre-defined styles I like, while not supporting things I feel aren't worth the hassle.

It has support for enough legacy ddoc that Phobos still works, but is really a different language - I think ddoc made a lot of mistakes (and markdown made mistakes too).

$(ADRDOX_SAMPLE
	Paragraphs just work.

	Automatically.

	$(LIST
		* Lists can be displayed
		* in bracketed markdown style
	)

	$(SMALL_TABLE
		markdown | style
		tables   | work (if bracketed)
	)

	---
	void d_code() {
	  is formatted brilliantly;
	}
	---

	```
	Markdown-style code blocks work too for other languages
	or convenient <pre> blocks.
	```

	```java
	public static void Main() {
		return "With some syntax highlighting."
	}
	```

	We also have `inline code`.

	$(TIP and various content boxes.)

	$(MATH \int \text{LaTeX} too! dx)
)


$(H2 Document outline)

Your comment consists of three parts: the first paragraph, which is meant to be a stand-alone summary which is shown out-of-context in search results, the synopsis, which is displayed "above the fold" - before the function prototype, member list, or automatically generated table of contents, and finally, the rest of the documentation.

The fold is inserted at the first "\n\n\n" it finds in your comment (the first time it sees two blank lines:

$(ADRDOX_SAMPLE

	This is the summary. It is shown in search results and
	at the top of your generated document.

	This is the synopsis, still displayed above the fold.

	So is this.


	The two blank lines above is the placeholder where the
	table of contents is inserted. This paragraph, and
	everything below it, is the bulk body of the page.

	Line breaks in the middle of a paragraph, except in code
	blocks, are ignored. You can format your comments however you like.
)

$(H2 Code snippets)

$(H3 Inline code)

Inline code can be marked with Markdown (and Ddoc) style $(BACKTICK)code here $(BACKTICK), which will render as `code here`. Text inside the backticks suppress all other documentation generator processing - it will just be escaped for literal output.

$(TIP If you need to display a literal $(BACKTICK), use the `$(BACKTICK)` macro.)

Code inside backticks may only span one line. If a line has an unmatched backtick, it is not processed as code.

If you want syntax-highlighted inline D code, use `$(D d code here)`, such as `$(D if(a is true))` will result in $(D if(a is true)) - notice the syntax highlighting on the D keywords.

$(H3 Block code)

There are three syntaxes for code blocks: Markdown style $(BACKTICK)$(BACKTICK)$(BACKTICK), ddoc style ---, and a magic macro called `$(CONSOLE)`.

All code blocks are outdented and leading and trailing blank lines are removed, but all other whitespace is left intact. This means you may indent it as much as you like inside your comments without breaking the output.

$(H4 Markdown style - for generic code)

The Markdown style block is meant to be used with generic code or preformatted text that is not D.

$(ADRDOX_SAMPLE
	```
	Code here 	which preserves
	   whitespace
	```
)

You can optionally include a language name after the opening ticks and it will label and attempt syntax highlighting (the syntax highlighter is not as precise as the D highlighter, but often should be good enough):

$(ADRDOX_SAMPLE
	```javascript
	/* This is highlighted Javascript! */
	window.onload = function() {
		var a = "hello, world!";
		var b = 5;
	};
	```

	```c
	/* Highlighted C */
	typedef struct {
		int a;
	} test;
	```

	```php
	<?php
		# highlighted PHP
		function foo($a) {
			return $a;
		}
	?>
	```

	```html
	<span class="foo">
		<!-- try hovering over the entity! -->
		HTML &amp;
	</span>
	```

	```css
	/* This also highlights */
	span[data-test="foo"] > .bar {
		color: red;
	}
	```
)

Currently supported languages for highlighting include: C, C++, Javascript, PHP, Java, C#, CSS, HTML, XML, and D. Though, for D, you should use ddoc style `---` delimiters to get the full-featured D highlighter instead of using the simpler one here. This simple highlighter aims for good enough to help visually on simple examples rather than being perfect on each target language.

$(TIP If you ever want to document the syntax of a Markdown code block itself, I added a magic $(BACKTICK)$(BACKTICK)$(BACKTICK){ code }$(BACKTICK)$(BACKTICK)$(BACKTICK) syntax. As long as the braces are nested, everything inside will be considered part of the literal code block, including other code blocks.)

The generator MAY syntax highlight the language using `span` with class names, but might not (really depends on if I implement it). You may use the language as a target in CSS using the `data-language` attribute to customize the appearance.

$(H4 Ddoc style - for D code)

The ddoc style block only works with D code. It runs the sample through the D lexer, so it understands things like nested documentation comments and will properly skip them while syntax highlighting the output.

$(ADRDOX_SAMPLE
---
/**
	Ddoc style code blocks understand D deeply.

	---
	if(example.nested)
		stillWorks!();
	---
*/
void main() {}
---
)

$(H4 Console macro - for console output)

The `$(CONSOLE)` macro is for copy/pasting text out of your console, such as showing command lines or program output. You MAY nest macros inside it for additional formatting, and thus, you should escape any `$` followed by `(` in the text.

$(ADRDOX_SAMPLE
$(CONSOLE
	$ dmd hello.d
	$ ./hello
	Hello, $(B world)!
)
)

$(H3 Documented unittests)

I also implemented the feature from ddoc where unittests with a documentation comment are appended to the examples section of the previous documented declaration.

$(H2 Cross-referencing)

Many tasks of cross-referencing are done automatically. Inheritance and function signatures use semantic data from the D source to link themselves. URLs in the raw text, such as http://dpldocs.info/ are detected and hyperlinked automatically. Tables of contents are created, as needed, by scanning for headers.

However, in your text, you may also want to reference names and links that are not automatically detected.

$(SIDEBAR It does not attempt to pick out D symbol names automatically from the text, since this leads to a great many false positives. ddoc's attempt to do this failed miserably.)

Since this is such a common task, I dedicated a short, special syntax to it: square brackets. Write a name or URL inside brackets and it will linkify it, as specifically as it can from the index built from semantic D data. For example: `[arsd.color]` will yield [arsd.color], a link to my color module.

When documenting code, it will first try to detect a URL. If so, it treats it as a link. Next, it will try to look up the D identifier in the current scope. If it finds it, it will link to the most local variable, following the import graph. If all else fails, it will just assume it is a relative filename and link that way.

$(NOTE
	If you want to load modules for name lookup, but not generate documentation for them, pass
	the file or the directory containing to `adrdox` with `--load`.
)

In most cases, putting a D name inside brackets should link as you expect.

You can also change the display name by putting a pipe after the link, followed by text: `[arsd.color|my color module]` gives [arsd.color|my color module].

Local sections can be referenced with `[#cross-referencing]`: [#cross-referencing].

$(H2 Paragraph detection)

The generator will automatically handle paragraph tags by looking for blank lines and other separators. Just write and trust it to do the right thing. (If it doesn't, email me a bug report, please.)

$(H2 Images)

You can post images with `$(IMG source_url, alt text)`. The default CSS will put some reasonable size limits and margin on it.

The image will typically be hosted elsewhere, `IMG` simply takes a URL (though it can be a data url, you need to manage that yourself too).

FIXME: implement and document `$(LEFT )`, `$(RIGHT )`, and `$(CENTERED )`.

You may also use inline `$(SVG )` or `$(RAW_HTML)`. FIXME

$(H2 Headers)

You use ddoc-style macros for headers: `$(H1 Name of header)`, `$(H2 Subheader)`, and so on through `$(H6)`. Linking will be added automatically by the generator.

$(H3 Ddoc sections)

Most the Ddoc sections are supported too, and should be used where appropriate to document your code. I also added one called `diagnostics:`, where you can list common compile errors seen with the function.

`Examples:` (or `Example:`) is special in that documented unit tests are appended here.

You may define custom ddoc sections as long as they are all one word and includes at least one underscore in the name. They will be translated to `H3` headers, since they typically go under the `Detailed Description` H2-level header.

Be sure to correctly nest headers - put H3 under H2, and H4 under H3, etc. Failure to do so may break your table of contents.

$(ADRDOX_SAMPLE
	$(H2 A header)
		Some content
	$(H3 Another header)
		Some more content

	A_Ddoc_Style_Header:
		And some content
)


$(H2 Content blocks)

There are a few content blocks to add boxes to your documentation: `$(TIP)`, `$(NOTE)`, `$(WARNING)`, `$(PITFALL)`, and `$(SIDEBAR)`. Inside these, you may write any content.

Use these boxes to make certain content stand out so the reader pays attention to something special (or, in the case of `SIDEBAR`, get out of the way so the reader can skip it). The intended semantics are:

`$(TIP)` is a cool fact to help you make the most of the code.

`$(NOTE)` is something the reader should be aware of, but they can get it wrong without major consequence.

`$(WARNING)` is something they need to watch out for, such as potential crashes or memory leaks when using the function.

`$(PITFALL)` is something that users very commonly get wrong and you want them to see it to avoid making the same mistake yet again.

`$(SIDEBAR)` will be typically displayed outside the flow of the text. It should be used when you want to expand on some details, but it isn't something the user strictly needs to know.

$(H2 Fancier Formatting)

$(SIDEBAR
	$(H3 Why use macro syntax to bracket it instead of trying to detect like Markdown does?)

	Basically, I have to support at least some of ddoc macro syntax anyway for compatibility with existing documents like Phobos, so it is a convenient thing to simplify my parser.

	But, beyond that, it also gives me a chance to accept metadata, like class names to add to the HTML by putting them inside the block too.
)

There are several magic macros that use domain-specific syntaxes for common formatting tasks, like lists and tables. The ddoc-style macro brackets the text, which is laid out in a particular way to make writing, reading, and editing the data most easy.


$(H3 Blockquotes)

Use the `$(BLOCKQUOTE)` macro to surround the quote. It will render as you expected.

$(ADRDOX_SAMPLE
	$(BLOCKQUOTE
		This is a quote! You can write whatever you want in here.

		Including paragraphs, and other content. Unlike markdown, you
		do not need to write `>` or spaces or anything else before every
		line, instead you just wrap the whole thing in `$(BLOCKQUOTE)`.

		If it has unbalanced parenthesis, you can use `$(LPAREN)` or `$(RPAREN)`
		for them.
	)
)

$(H3 Lists)

There are two types of list: `$(LIST)` and `$(NUMBERED_LIST)`. Both work the same way. The only difference is `$(LIST)` generates a `<ul>` tag, while `$(NUMBERED_LIST)` generates a `<ol>` tag.

Inside the magic list macros, a `*` character at the beginning of a line will create a new list item.

$(ADRDOX_SAMPLE
	$(LIST
		* List item
		* Another list item
	)

	$(NUMBERED_LIST
		* One
		* Two
		* Three
	)
)

Text inside the list items is processed normally. You may nest lists, have paragraphs inside them, or anything else.

$(TIP You can add a class name to the list element in the HTML by using the `$(CLASS)` magic macro before opening your first list item. Use this class, along with CSS, to apply custom style to the list and its items.)

You may also use `$(RAW_HTML)` for full control of the output, or legacy Ddoc style `$(UL $(LI ...))` macros to form lists as well.

$(H3 Tables)

I support two table syntaxes: list tables (by row and by column, inspired by reStructuredText) and compact tables, with optional ASCII art (inspired by Markdown).

$(H4 Compact Tables)

A compact table consists of an optional one-line caption, a one-line header row, and any number of one-line data rows.

Cells are separated with the `|` character. Empty cells at the beginning or end of the table are ignored, allowing you to draw an ASCII art border around the table if you like.

The first row is always considered the header row. Columns without header text are also considered header columns.

The minimal syntax to define a table is:

$(ADRDOX_SAMPLE
	$(SMALL_TABLE
		Basic table caption (this line is optional)
		header 1|header 2
		data 1|data 2
		more data | more data
	)
)

$(TIP Since the ddoc-style macro bracketing the table must have balanced parenthesis, any unbalanced parenthesis character inside should be put inside a $(BACKTICK)code block$(BACKTICK). You can also put pipe characters inside code blocks:

	$(ADRDOX_SAMPLE
	$(SMALL_TABLE
		h1|h2
		`d1|with pipe`|d2
	)
	)
)

ASCII art inside the compact table is allowed, but not required. Any line that consists only of the characters `+-=|` is assumed to be decorative and ignored by the parser. Empty lines are also ignored. White space around your cells are also ignored.

The result is you can style it how you like. The following code will render the same way as the above table:

$(ADRDOX_SAMPLE
$(SMALL_TABLE
	Basic table caption (this line is optional)
	+-----------+-----------+
	| header 1  | header 2  |
	+===========+===========+
	| data 1    | data 2    |
	| more data | more data |
	+-----------+-----------+
)
)

$(H5 Two-dimensional tabular data)

If a table has an empty upper-left cell, it is assumed to have two axes. Cells under the column with the empty header are also rendered as headers.

Here is a two-dimensional table with and without the optional ascii art.

$(ADRDOX_SAMPLE
$(SMALL_TABLE

	XOR Truth Table
	+-----------+
	|   | 0 | 1 |
	+===|===|===+
	| 0 | F | T |
	| 1 | T | F |
	+-----------+
)

$(SMALL_TABLE
	Alternative XOR
	||0|1
	0|F|T
	1|T|F
)
)

Notice that even without the ascii art, the outer pipe is necessary to indicate that an empty cell was intended in the upper left corner.

$(TIP
	If you want to make a feature table, you can do it as a compact
	table with any entry for yes, and no data for no.

	$(ADRDOX_SAMPLE
	$(SMALL_TABLE
		Features
		|| x | y
		a| * |
		b|   | *
		c| * | *
	)
	)

	You can then style these with CSS rules like `td:empty` in lieu of adding a class to each element. The empty cell on the right did not require an extra `|` because all data rows are assumed to have equal number of cells as the header row.
)

$(H4 Longer tables)

I also support a list table format, inspired by restructuredText.

	$(ADRDOX_SAMPLE
	$(TABLE_ROWS
		Caption
		* + Header 1
		  + Header 2
		* - Data 1
		  - Data 2
		* - Data 1
		  - Data 2
	)
	)

In this format, the text before any `*` is the caption. Then, a leading `*` indicates a new row, a leading `+` starts a new table header, and a leading `-` starts a new table cell. The cells can be as long as you like.


$(H4 Formatting tables)

To format tables, including aligning text inside a column, add a class name to the tag using the magic `$(CLASS name)` macro right inside the table backeting, then target that with CSS rules in your stylesheet.

	$(ADRDOX_SAMPLE
	$(RAW_HTML
		<style>
		.my-yellow-table {
			background-color: yellow;
		}
		</style>
	)
	$(TABLE_ROWS
		$(CLASS my-yellow-table)
		Caption
		* + Header 1
		  + Header 2
		* - Data 1
		  - Data 2
		* - Data 1
		  - Data 2
	)
	)


$(H4 More advanced tables)

To avoid complicating the syntax in more common cases, I do not attempt to support everything possible. Notably, most cases of colspan and rowspan cannot be expressed in any of my syntaxes.

If you need something, and all else fails, you can always use the `$(RAW_HTML)` escape hatch and write the code yourself.

$(H2 Mathematics)

The doc generator can also render LaTeX formulas, if latex and dvipng is installed on your system.

$(ADRDOX_SAMPLE
	$(MATH \int_{1}^{\pi} \cos(x) dx )
)

Note that generating these images is kinda slow. You must balance parenthesis inside the macro, and all the output images will be rendered inline, packed in the html file.

If you can use a plain text or html character btw, you should. Don't break out MATH just for an $(INF) symbol, for example.

$(H2 Ddoc Macro to HTML Tag reference)

$(LIST
	* `$(IMG source_url, alt text)`
	* `$(B bold text)`
	* `$(I italic text)`
	* `$(U underlined text)`
	* `$(SUPERSCRIPT superscript text)`
	* `$(SUB subscript text)`
)

$(H2 Footnotes)

adrdox supports footnotes[1] and popup notes[2], scoped to the declaration attached to the comment. The syntax is to simply write `[n]`, such as `[1]`, where you want it to be displayed, then later in the comment, write a `Link_References:` section at the end of your comment, like so:

```
Link_References:
	1 = https://en.wikipedia.org/wiki/Footnote
	2 = This note will popup inline.
```

Undefined footnote references output the plain text without modification, like [3]. Numeric footnotes can only be used locally, they must be used and defined inside the same comment.

$(NOTE Text references must always be contained to a single line in the current implementation.)

If you need something more complex than a single link or line of text, write a section for your notes inside your comment and use the `[n]` Link_References to link to it:

---
/++
	This huge complex function needs a complex footnote[1].

	$(H2 Footnotes)

	$(DIV $(ID note-1)
		This can be arbitrarily complex.
	)

	Link_References:
		1 = [a_huge_complex_function#note-1]
+/
void a_huge_complex_function() {}
---

See that live [a_huge_complex_function|here].

You can also do custom links, images, or popup text via the shortcut `[reference]` syntax. You can define them with a symbol name in the Link_References section:

```
Link_References:
	dlang = http://dlang.org/
	dlogo = $(IMG /d-logo.png, The D Logo)
	dmotto = Modern convenience. Modeling power. Native efficiency.
```

You can now reference those with `[dlang], [dlogo], and [dmotto]`, which will render thusly: [dlang], [dlogo], [dmotto]. Be aware that ONLY a single line of plain text, a single `$(IMG)`, or a single link (url or convenience reference, see below) are allowed in the `Link_References` section.

$(NOTE
	Link references will override D name lookup. Be aware of name clashes that might
	break convenient access to in-scope symbol names.
)

Like with other convenience links, you can change the displayed text by using a pipe character, like `[dlang|The D Website]`. It will continue to link to the same place or pop up the same text. If the name references an image, the text after the pipe will locally change the `alt` text on the image tag.

Additionally, the pipe character can be used in the reference definition to change the default display text:

```
Link_References:
	input_range = [std.range.primitives.isInputRange|input range]
```

will always show "input range" when you write `[input_range]`, but can still be overridden by local text after the pipe, like `[input_range|an input range]`. Those will render: [input_range] and [input_range|an input range].

$(TIP
	Yes, you can define link references in terms of a D reference. It will look up the name using the normal scoping rules for the attached declaration.
)

$(WARNING
	If you use a reference in a global reference definition, it will look up the name in the scope at the *usage point*. This may change in the future.
)

Unrecognized refs are forwarded to regular lookups.

While numeric link references are strictly scoped to the declaration of the attached comment, text link references are inherited by child declarations. Thus, you can define shortcuts at module scope and use them throughout the module. You can even define one in a package and use it throughout the package, without explicitly importing the `package.d` inside the module. Link references, however, are $(I not) imported like normal D symbols. They follow a strict parent->child inheritance.

If you need a link reference to be used over and over across packages, you may also define global link references in a text file you pass to adrdox with the `--link-references` option. The format of this text file is as follows:

```
	name = value
	othername = other value
```

Yes, the same as the `Link_References:` section inside a comment, but with no surrounding decoration.

$(PITFALL Be especially careful when defining global textual link macros, because they will override normal name lookups when doing `[convenient]` cross references across the entire current documentation build set.)

You may want to give unique, yet convenient names to common concepts used throughout your library and define them as Link_References for easy use.

Link_References:
	1 = http://dpldocs.info/
	2 = Popup notes are done as <abbr> tags with title attributes.
	input_range = [std.range.primitives.isInputRange|input range]
	dlang = http://dlang.org/
	dlogo = $(IMG /d-logo.png, The D Logo)
	dmotto = Modern convenience. Modeling power. Native efficiency.

$(H2 Side-by-side comparisons)

You might want to show two things side by side to emphasize how the user's existing knowledge can be shared. You can do that with the `$(SIDE_BY_SIDE $(COLUMN))` syntax:

$(ADRDOX_SAMPLE
	$(SIDE_BY_SIDE
		$(COLUMN
			```php
			<?php
				$foo = $_POST["foo"];
			?>
			```
		)
		$(COLUMN
			---
			import arsd.cgi;
			string foo = cgi.post["foo"];
			---
		)
	)
)

Try to keep your columns as narrow as reasonable, so they can actually be read side-by-side!

$(H2 Commenting stuff out in comments)

The macro `$(COMMENT ...)` is removed from the generated document. You can use it to comment
stuff out of your comment. Of course, you can also just use regular `/*` comments instead of
`/**`.

+/
module adrdox.syntax;

/+
/// penis
struct A {
	/// vagina
	union {
		/// ass
		int a;
		/// hole
		int b;
	}
}
+/


/*

$(H3 Code with output)

The magic macro `$(CODE_WITH_OUTPUT)` is used to pair a block of code with a block of output, side-by-side. The first code block in the macro is considered the code, and the rest of the content is the output.

As a special case, if the code is of the `adrdox` language, you do not need to provide output; it will render automatically. (I added that feature to make writing this document easer.) I might add other language filters too, probably by piping it out to some command line, if there's demand for it.

I intend for this to be used to show syntax translations, but any time where a side-by-side view may be useful you can give it a try.

*/
/++
	This huge complex function needs a complex footnote[1].

	$(H2 Footnotes)

	$(DIV $(ID note-1)
		This can be arbitrarily complex.
	)

	Link_References:
		1 = [a_huge_complex_function#note-1]
+/
void a_huge_complex_function() {}

