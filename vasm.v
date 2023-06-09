import os
import flag
import lib.restr {String}

fn main() {
	mut fprs := flag.new_flag_parser(os.args)
	fprs.application('vasm')
	fprs.version('0.0.1')
	fprs.description('')
	fprs.skip_executable()

	root := fprs.string('root', `d`, '', 'Root directory')

	additional_args := fprs.finalize() or {
		eprintln(err)
		println(fprs.usage())
		return
	}

	path := additional_args[0]

	if path != '' {
		mut txt := os.read_file(path)!
		for {
			txt = String(txt).replace(r'\(rm\|.*\|\)', '')

			// apply vars
			doc_start, doc_end := String(txt).find(r'<var>.*</var>')
			if doc_start >= 0 {
				mut doc := txt[doc_start+5 .. doc_end-6].trim('\n')
				doc = String(doc).replace(r'<!--.*-->', '')
				vars := doc.split('\n')
				for kvln in vars {
					kv := kvln.split('=')
					k := kv[0].trim(' ')
					mut v := ''
					if kv.len > 1 { v = kv[1].trim(' ') }
					txt = String(txt).replace(r'\{\{'+k+r'\}\}', v)
				}
				txt = String(txt).replace(r'<var>.*</var>', '')
			}

			// load [ins](.*)
			start, end := String(txt).find(r'\[ins\]\((.*)\)')
			if start == -1 {break}

			mut comp := txt[start+6 .. end-1]
			comp = os.read_file(root + comp)!
			txt = txt[..start] + comp + txt[end..]
		}
		
		println(txt.trim(' ').trim('\n'))
		return
	}

	println(additional_args.join_lines())
	println(fprs.usage())
}