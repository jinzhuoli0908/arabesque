# Arabesque rules

Arabesque is a macOS input method for typing French and German letters on a US QWERTY keyboard. You hold ⌥ (Option) and press a short sequence of keys. This document defines what each sequence types.

Arabesque is made for US QWERTY keyboards, and the keys are the ones printed on them: `a` is the A key and `;` is the semicolon key.

The result depends on whether ⌥ stays down between keys. ⌥(u s) means hold ⌥, press u, press s, then release ⌥. It gives û. ⌥(u) ⌥(s) releases ⌥ between the two keys and gives üß.

## Terms

- **Hold**: the time from when either ⌥ key goes down until both ⌥ keys are up. ⌥(x y) means x and then y are pressed in one hold. ⌥(x) ⌥(y) means ⌥ is released in between. A key outside the parentheses is pressed without ⌥: ⌥(;) e means hold ⌥ and press `;`, release ⌥, then press e.
- **Scheme keys**: the keys a, o, u, s, c, e, i, y and `;` on a US QWERTY keyboard.
- **Character key**: a letter, digit or punctuation key, or the space bar. Function keys (R10, R11) are not character keys.
- **Accented letter**: any letter that the core table produces (the 6 single-key letters, the 10 two-key letters, the 4 postfix tréma letters, and the 4 tréma letters typed with the dead key). ß, æ and œ count as accented letters here.
- **Marked letter**: a letter that is shown underlined because it is not final yet. macOS calls this marked text. When a marked letter is committed, the underline goes away and the letter stays.
- **Plain character**: what the key types without ⌥, given the state of Shift and Caps Lock.
- **Core table**: the table in the Core table section. It defines what Arabesque types, and the other rules never change it.
- **Convenience rules**: the rules in the Rules and Capitals sections. They are there to make typing easier, and they only handle cases the core table does not define.
- **ABC**: the US QWERTY layout called ABC in macOS. The U.S. layout types the same characters.

## Core table

The core table has 24 entries:

- 6 single-key letters, such as ⌥(a) = ä;
- 10 two-key letters, such as ⌥(a s) = â;
- 4 postfix tréma letters, typed as the letter and then `;`, such as ⌥(e ;) = ë;
- the same 4 tréma letters typed with the dead key, `;` first and then the letter, such as ⌥(;) e = ë.

<!-- core:begin -->
| Keys | Result |
|---|---|
| `⌥(a)` | `ä` |
| `⌥(o)` | `ö` |
| `⌥(u)` | `ü` |
| `⌥(s)` | `ß` |
| `⌥(c)` | `ç` |
| `⌥(e)` | `é` |
| `⌥(a a)` | `à` |
| `⌥(a s)` | `â` |
| `⌥(a e)` | `æ` |
| `⌥(e e)` | `è` |
| `⌥(e s)` | `ê` |
| `⌥(i s)` | `î` |
| `⌥(o s)` | `ô` |
| `⌥(o e)` | `œ` |
| `⌥(u u)` | `ù` |
| `⌥(u s)` | `û` |
| `⌥(e ;)` | `ë` |
| `⌥(i ;)` | `ï` |
| `⌥(u ;)` | `ü` |
| `⌥(y ;)` | `ÿ` |
| `⌥(;) e` | `ë` |
| `⌥(;) i` | `ï` |
| `⌥(;) u` | `ü` |
| `⌥(;) y` | `ÿ` |
<!-- core:end -->

- **Dead key.** ⌥(;) is a dead key. It shows an underlined ¨ and waits. If the next key is e, i, u or y, you get ë, ï, ü or ÿ. You can press that key with or without ⌥ (R6).
- **Postfix tréma.** While ⌥ is held, e, i, u or y followed by `;` gives ë, ï, ü or ÿ, the same four letters that the dead key types. This works like the two-key letters: first the letter, then the key that changes it.
- **Key order.** Each entry has one fixed key order, so ⌥(e a) is not æ. The tréma letters have two tréma entries each: one with the dead key first, ⌥(;) e = ë, and one with the letter first, ⌥(e ;) = ë.
- **Umlaut and tréma.** The German umlauts ä, ö and ü take one key each. The French tréma letters ë, ï, ü and ÿ are kept apart from them on purpose and are typed with `;`.
- **One character each.** Every result is a single precomposed character (NFC). All three ways of typing ü, ⌥(u), ⌥(;) u and ⌥(u ;), give U+00FC, because Unicode does not tell an umlaut from a tréma.
- **Capitals.** See Capitals. The capital of ß is ẞ (U+1E9E).

## Rules

The rules below are numbered R1 to R16, so that the code and the tests can refer to them. Together with the rules under Capitals, they are the convenience rules, and they follow two principles:

1. They never change any result of the core table.
2. When there is no sensible result, they play safe: they cancel, type nothing, or type the plain character. They do not guess by splitting the keys into two accented letters: ⌥(e c) gives éc, not éç.

### During a hold

**R1** One hold produces at most one accented letter. Every character key after it in the same hold types its plain character: ⌥(c a) = ça, ⌥(u c k) = ück as in zurück, ⌥(s e) = ße as in große, and ⌥(o e i) = œi as in œil.

R1 is there for a common slip, releasing ⌥ one key too late: when you type très, ⌥(e e s) gives ès and not èß. To type two accented letters in a row, release ⌥ between them: ⌥(e) ⌥(c) = éç, as in déçu.

**R2** The keys a, e, i, o, u and y wait after you press them, since another key may combine with them. A waiting letter is shown as a marked letter.

- If the next key forms a two-key entry of the core table with the waiting letter, the two keys become that entry's letter. This includes the postfix tréma (R8).
- If not, the waiting letter is committed as its single-key letter, and the next key types its plain character (R1): ⌥(a o) = äo. For i and y, which have no single-key letter, see R3.
- The keys c and s start no entry, so they give ç and ß right away.
- Once two keys have formed a letter, later keys do not change it: ⌥(e e s) = ès.

**R3** ⌥(i) and ⌥(y) on their own type a plain i and y. They are not accented letters, so R1 does not apply to them, and an accented letter can still follow in the same hold: ⌥(i e e) = iè, as in dernière.

**R4** While ⌥ is held and the hold has no accented letter yet, keys outside the scheme work like this (see Symbol keys):

- Letters, the space bar, `'` and `` ` `` type their plain character: ⌥(t e) = té.
- Other digit and punctuation keys type ABC's ⌥ symbol, or ABC's ⌥⇧ symbol when Shift is held: ⌥(-) = –, ⌥(⇧-) = —.
- None of these are accented letters, so R1 does not apply to them.

⌥ often goes down one key too early, before the letter that needs it. A letter typed under that early ⌥ must stay plain, as t does in ⌥(t e). Digits and punctuation keep ABC's symbols, such as « » – — €, because an early ⌥ seldom lands on them.

**R5** Holding ⌥ alone, without pressing another key, shows and types nothing.

### Dead key

**R6** After `;` starts the dead key, the next key gives the same result whether or not ⌥ is still held: ⌥(; e) = ⌥(;) e = ë, and ⌥(; a) = ⌥(;) a = a.

**R7** If the next key is not e, i, u or y, the dead key is cancelled quietly. No lone ¨ is typed. A character key then types its plain character, whether or not ⌥ is held. If ⌥ is held, the hold counts as having an accented letter, so later character keys in it are plain too, as with R1: ⌥(; a s) = as. Function keys work as usual (R10, R11).

**R8** Pressing `;` right after a waiting e, i, u or y makes the postfix tréma letter from the core table: ⌥(i ;) = ï. Otherwise `;` is the dead key, but only if the hold has no accented letter yet. After an accented letter, `;` types a plain `;` (R1): ⌥(a ;) = ä;. A plain letter does not count, so `;` is still the dead key after it: ⌥(t ; e) = të.

### Display and commit

**R9** An accented letter made during a hold is first shown as a marked letter. It is committed when you release ⌥ or press the next key. This holds for single-key letters, two-key letters, and tréma letters typed while ⌥ is held.

- While the dead key waits, an underlined ¨ is shown.
- Releasing ⌥ does not affect the dead key. It keeps waiting for the next key.
- A tréma letter typed without ⌥ is committed at once. In ⌥(;) e, the ë appears without an underline.

**R10** ⌫ (Delete) or ⎋ (Esc):

- If there is a marked letter or a waiting dead key, the key only cancels it and does not reach the app. After that, the hold counts as having no accented letter yet: ⌥(c ⌫ e s) = ê.
- If nothing is marked, the key goes to the app as usual. For example, ⌥⌫ deletes a word.

**R11** Function keys (Return, Tab, the arrow keys, Home, End, Page Up, Page Down, ⌦, the F keys and the numeric keypad) first commit the marked letter. Then the key goes to the app, together with ⌥. A key that Arabesque does not know is handled the same way.

**R12** A shortcut with ⌘ or ⌃ commits the marked letter and cancels the dead key. The key goes to the app unchanged.

**R13** An interruption commits the marked letter and cancels the dead key. Interruptions are a mouse click, switching apps, switching input sources, and the system asking the input method to commit.

### Autorepeat, the two ⌥ keys and typing without ⌥

**R14** While ⌥ is held, autorepeat of the scheme keys (including `;`) is ignored. Other keys repeat as usual. So if you hold e down a little too long, you still get é and not è.

**R15** The left and right ⌥ keys are the same. If you switch sides during a hold, by pressing the other ⌥ before you release the first, it is still one hold.

**R16** Without ⌥, keys type as on the ABC layout. Arabesque does not keep the layout you used before you switched to it.

## Capitals

- **Single-key letters** are capitals if you hold Shift while you press the key, or if Caps Lock is on: ⌥(⇧a) = Ä. Here ⇧a means a is pressed while Shift is held.
- **Two-key letters** are capitals if you hold Shift for either key, or if Caps Lock is on: ⌥(⇧e s) = ⌥(e ⇧s) = Ê. The postfix tréma works the same way: ⌥(⇧i ;) = ⌥(i ⇧;) = Ï.
- **Tréma letters from the dead key** are capitals if you hold Shift for the letter after `;`, or if Caps Lock is on. Shift on `;` does not count here, and ⌥(⇧;) is the dead key too: ⌥(; ⇧e) = Ë, but ⌥(⇧; e) = ë.
- **Plain characters** follow the usual rules. Letters are capitals with Shift or Caps Lock. Other keys type their Shift character when Shift is held, such as ! on 1.
- **ß** becomes ẞ (U+1E9E), both with ⌥(⇧s) and with ⌥(s) when Caps Lock is on.
- **Symbols** (R4) follow Shift only, not Caps Lock.

### Tapping Shift

While ⌥ is held, you can also tap Shift: press it and release it, with no other key in between. The tap can come before or after the letter. Below, ⇧ on its own is a tap.

- If a letter is marked when you tap, it becomes a capital at once.
  - Single-key letters: ⌥(a ⇧) = Ä, ⌥(e ⇧) = É, ⌥(c ⇧) = Ç, ⌥(s ⇧) = ẞ.
  - Two-key and tréma letters: ⌥(e e ⇧) = È, ⌥(i s ⇧) = Î, ⌥(; e ⇧) = Ë.
  - A waiting i or y counts too: ⌥(i ⇧ s) = Î.
  - This happens as soon as Shift goes down, so a Shift meant for the next key also capitalizes the marked letter: ⌥(a ⇧o) = ÄO.
- If nothing is marked, or the ¨ is waiting, the tap is kept for the next key, which then counts as typed with Shift: ⌥(⇧ e) = É, ⌥(⇧ e e) = È, ⌥(⇧ c a) = Ça, ⌥(; ⇧ e) = Ë, ⌥(⇧ t) = T, ⌥(⇧ -) = —. A second tap does not undo the first.
- A kept tap only applies to what Arabesque types itself. A function key, a ⌘ or ⌃ shortcut, or an interruption (R13) cancels it. The dead key uses it up, but `;` has no capital, so ⌥(⇧ ; e) = ë.
- Only a pure tap is kept. If you press a key while Shift is down, Shift and that key form a chord, which is not a tap. So ⌥(⇧e) = É works as usual. And if ⌥ goes down too early while you type Déjà, the Shift you use for the D does not make the é a capital.
- Arabesque checks Shift when it is released, so you can also press Shift, then ⌥, and release Shift first. Shift counts as a pure tap when all of these are true:
  - ⌥ is held when Shift is released;
  - no key was pressed since Shift went down;
  - ⌥ was not released in between;
  - nothing interrupted (R13).
- A tap only works during the current hold. Releasing ⌥ cancels a kept tap, and a tap after ⌥ is released does nothing. Releasing Shift does not turn a capital back into a small letter.

## Symbol keys

While ⌥ is held and the hold has no accented letter yet, the digit and punctuation keys type ABC's symbols (R4). These are the symbols ABC types with ⌥ and ⌥⇧. "Plain" means the key types its plain character. Letters outside the scheme are not listed: they type their plain character.

| Key | ⌥ | ⌥⇧ |
|---|---|---|
| `` ` `` | `` ` `` (plain) | `~` (plain) |
| `1` | `¡` | `⁄` |
| `2` | `™` | `€` |
| `3` | `£` | `‹` |
| `4` | `¢` | `›` |
| `5` | `∞` | `ﬁ` |
| `6` | `§` | `ﬂ` |
| `7` | `¶` | `‡` |
| `8` | `•` | `°` |
| `9` | `ª` | `·` |
| `0` | `º` | `‚` |
| `-` | `–` | `—` |
| `=` | `≠` | `±` |
| `[` | `“` | `”` |
| `]` | `‘` | `’` |
| `\` | `«` | `»` |
| `'` | `'` (plain) | `"` (plain) |
| `,` | `≤` | `¯` |
| `.` | `≥` | `˘` |
| `/` | `÷` | `¿` |
| Space bar | space (plain) | space (plain) |
| `§` (ISO keyboards) | `§` | `±` |

## Examples

Every row below is an automated test. `SpecExampleTests` types the keys and checks the result, and `RulesDocumentTests` checks that these tables match those tests.

Notation:

- `⌥( … )`: one hold. The keys inside are pressed in order while ⌥ is held. Keys outside the parentheses are pressed without ⌥.
- A space separates two key presses. So `⌥(⇧ e)` (tap Shift, then press e) and `⌥(⇧e)` (press e while Shift is held) are different sequences, even though both give É.
- `⇧x`: Shift goes down, x is pressed, then Shift comes up (a chord). The Shift press already acts on a marked letter (see Capitals), so ⌥(a ⇧o) = ÄO. Because x was pressed while Shift was down, this is not a tap and is not kept for the next key.
- `⇧` on its own: a Shift tap. Shift is pressed and released with no other key in between.
- `x*`: an autorepeat of x, as when x is held down.
- `␣`: the space bar.
- `⌫`: Delete. `⎋`: Esc. `⏎`: Return. These are function keys.
- `⌘x`: x pressed with ⌘. A shortcut typed during a hold is listed as `⌘x`, even though ⌥ is still down.
- `CLICK`: an interruption, such as a mouse click (R13).
- `⇪` at the start of a row: Caps Lock is on.

Result is the text that gets typed. `(nothing)` means no text, and `␣` in a result is a space. Sent to the app lists the keys that Arabesque passes to the app to act on, such as `⌥⌫`, which deletes a word. Rule names the rule that gives the result; Core means the core table.

<!-- examples:begin -->

### Core table entries

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(a)` | `ä` | | `Core` |
| `⌥(u s)` | `û` | | `Core` |
| `⌥(u) ⌥(s)` | `üß` | | `Core` |
| `⌥(e e)` | `è` | | `Core` |
| `⌥(e) ⌥(e)` | `éé` | | `Core` |
| `⌥(a e)` | `æ` | | `Core` |
| `⌥(o e)` | `œ` | | `Core` |
| `⌥(i s)` | `î` | | `Core` |
| `⌥(;) i` | `ï` | | `Core` |
| `⌥(;) y` | `ÿ` | | `Core` |
| `⌥(; e)` | `ë` | | `R6` |
| `⌥(e ;)` | `ë` | | `Core` |
| `⌥(i ;)` | `ï` | | `Core` |
| `⌥(u ;)` | `ü` | | `Core` |
| `⌥(y ;)` | `ÿ` | | `Core` |

### Holds, other keys and the dead key

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(c a)` | `ça` | | `R1` |
| `⌥(e e s)` | `ès` | | `R1` |
| `⌥(u c k)` | `ück` | | `R1` |
| `⌥(s e)` | `ße` | | `R1` |
| `⌥(e c)` | `éc` | | `R1` |
| `⌥(e) ⌥(c)` | `éç` | | `Core` |
| `⌥(a o)` | `äo` | | `R1, R2` |
| `⌥(i)` | `i` | | `R3` |
| `⌥(i e e)` | `iè` | | `R3` |
| `⌥(y)` | `y` | | `R3` |
| `⌥(y e)` | `yé` | | `R3` |
| `⌥(i ; e)` | `ïe` | | `R1` |
| `⌥(o e i)` | `œi` | | `R1` |
| `⌥(t e)` | `té` | | `R4` |
| `⌥(a ;)` | `ä;` | | `R8` |
| `⌥(;) x` | `x` | | `R7` |
| `⌥(; a)` | `a` | | `R7` |
| `⌥(; a s)` | `as` | | `R7` |
| `⌥(;) ⌥(a)` | `a` | | `R6, R7` |
| `⌥(-)` | `–` | | `R4` |
| `⌥(⇧-)` | `—` | | `R4` |
| `⌥(\)` | `«` | | `R4` |
| `⌥(⇧\)` | `»` | | `R4` |
| `⌥(␣)` | `␣` | | `R4` |
| `⌥(e ␣)` | `é␣` | | `R1` |
| `⌥(e ,)` | `é,` | | `R1` |
| `⌥(')` | `'` | | `R4` |

### Shift and Caps Lock

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(⇧a)` | `Ä` | | `Capitals` |
| `⌥(⇧e s)` | `Ê` | | `Capitals` |
| `⌥(e ⇧s)` | `Ê` | | `Capitals` |
| `⌥(⇧e c)` | `Éc` | | `R1, Capitals` |
| `⌥(⇧c ⇧a)` | `ÇA` | | `R1, Capitals` |
| `⌥(⇧s)` | `ẞ` | | `Capitals` |
| `⌥(⇧i ;)` | `Ï` | | `Capitals` |
| `⌥(i ⇧;)` | `Ï` | | `Capitals` |
| `⌥(; ⇧e)` | `Ë` | | `Capitals` |
| `⌥(⇧; e)` | `ë` | | `Capitals` |
| `⌥(⇧i)` | `I` | | `R3, Capitals` |
| `⌥(⇧t)` | `T` | | `R4, Capitals` |
| `⌥(e ⇧)` | `É` | | `Capitals` |
| `⌥(e e ⇧)` | `È` | | `Capitals` |
| `⌥(c ⇧)` | `Ç` | | `Capitals` |
| `⌥(s ⇧)` | `ẞ` | | `Capitals` |
| `⌥(o e ⇧)` | `Œ` | | `Capitals` |
| `⌥(a ⇧)` | `Ä` | | `Capitals` |
| `⌥(i s ⇧)` | `Î` | | `Capitals` |
| `⌥(; e ⇧)` | `Ë` | | `Capitals` |
| `⌥(i ; ⇧)` | `Ï` | | `Capitals` |
| `⌥(i ⇧ s)` | `Î` | | `R3, Capitals` |
| `⌥(a ⇧o)` | `ÄO` | | `R1, Capitals` |
| `⌥(; ⇧ e)` | `Ë` | | `Capitals` |
| `⌥(e) ⇧` | `é` | | `Capitals` |
| `⌥(⇧ e)` | `É` | | `Capitals` |
| `⌥(⇧ e e)` | `È` | | `Capitals` |
| `⌥(⇧ a s)` | `Â` | | `Capitals` |
| `⌥(⇧ c a)` | `Ça` | | `R1, Capitals` |
| `⌥(⇧ t)` | `T` | | `R4, Capitals` |
| `⌥(⇧ -)` | `—` | | `R4, Capitals` |
| `⌥(⇧ ; e)` | `ë` | | `Capitals` |
| `⌥(⇧ ⏎ e)` | `é` | `⌥⏎` | `R11, Capitals` |
| `⌥(⇧) e` | `e` | | `Capitals` |
| `⇪ ⌥(s)` | `ẞ` | | `Capitals` |
| `⇪ ⌥(i s)` | `Î` | | `Capitals` |
| `⇪ ⌥(i)` | `I` | | `Capitals` |
| `⇪ ⌥(;) e` | `Ë` | | `Capitals` |
| `⇪ ⌥(-)` | `–` | | `Capitals` |

### Delete

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(a ⌫)` | `(nothing)` | | `R10` |
| `⌥(c ⌫)` | `(nothing)` | | `R10` |
| `⌥(e e ⌫)` | `(nothing)` | | `R10` |
| `⌥(; ⌫)` | `(nothing)` | | `R10` |
| `⌥(a ⌫ o)` | `ö` | | `R10` |
| `⌥(⌫)` | `(nothing)` | `⌥⌫` | `R10` |

### Autorepeat

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(e e*)` | `é` | | `R14` |
| `⌥(e e* s)` | `ê` | | `R14` |
| `⌥(o o*)` | `ö` | | `R14` |
| `⌥(y y*)` | `y` | | `R14` |

### Return, shortcuts and clicks

| Keys | Result | Sent to the app | Rule |
|---|---|---|---|
| `⌥(a ⏎)` | `ä` | `⌥⏎` | `R11` |
| `⌥(e ⌘s)` | `é` | `⌘s` | `R12` |
| `⌥(a CLICK)` | `ä` | | `R13` |
| `⌥(;) CLICK x` | `x` | | `R13` |

<!-- examples:end -->
