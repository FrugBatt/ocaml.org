---
title: 'Tutorial: How to Port Lwt Applications to Eio'
description: "Thomas Leonard and Jonathan Ludlam hosted a tutorial on porting Lwt
  applications to OCaml 5 and Eio at arguably the world's largest\u2026"
url: https://tarides.com/blog/2023-09-27-tutorial-how-to-port-lwt-applications-to-eio
date: 2023-09-27T00:00:00-00:00
preview_image: https://tarides.com/static/c9e532147350a2b7972bde7040c6f3f6/68e58/bifurcated.jpg
featured:
authors:
- Tarides
source:
---
    
<p>Thomas Leonard and Jonathan Ludlam hosted a <a href="https://icfp23.sigplan.org/details/icfp-2023-tutorials/4/Porting-Lwt-applications-to-OCaml-5-and-Eio">tutorial on porting Lwt applications to OCaml 5 and Eio</a> at arguably the world's largest functional programming conference: <a href="https://icfp23.sigplan.org">ICFP</a>. The tutorial is a great introduction to Eio, with a clear step-by-step approach that is accessible to developers of different experience levels.</p>
<p>This article provides some context to the tutorial and Eio in general. If you would rather skip straight to the code, check out the <a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/tree/main">tutorial on GitHub.</a></p>
<h2 style="position:relative;"><a href="https://tarides.com/feed.xml#eio-a-brief-introduction" aria-label="eio a brief introduction permalink" class="anchor before"><svg aria-hidden="true" focusable="false" height="16" version="1.1" viewbox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Eio: a Brief Introduction</h2>
<p>OCaml 5 brought support for programming with effects. Using effects has several advantages over using call-backs or monadic style:</p>
<ol>
<li>It is faster &ndash; no heap allocations are required to simulate a stack.</li>
<li>Concurrent and plain non-concurrent code can be written in the same style.</li>
<li>Exception backtraces work.</li>
<li>Other language features such as <code>try/with</code>, <code>match</code>,<code> while</code> etc can be used with concurrent code.</li>
</ol>
<p>The OCaml 5 update also brought Multicore support, which has big implications for better performance across a multitude of <a href="https://tarides.com/blog/2022-03-01-segfault-systems-joins-tarides/#ecosystem">use cases.</a></p>
<p>In light of these changes, there was a lot of interest in moving existing OCaml code to a new I/O library that could make the best use of both effects and multiple cores. With this impetus, a new effects-based direct-style I/O stack was developed for OCaml &ndash; enter Eio.</p>
<h3 style="position:relative;"><a href="https://tarides.com/feed.xml#why-eio" aria-label="why eio permalink" class="anchor before"><svg aria-hidden="true" focusable="false" height="16" version="1.1" viewbox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Why Eio?</h3>
<p>Beyond Multicore and effects support, Eio comes with several useful features such as making use of lock-free data structures (see <a href="https://github.com/ocaml-multicore/saturn">Saturn</a>, modular programming support, interactive monitoring support enabled by the custom runtimes in OCaml 5.1, and interoperability with other concurrency libraries such as Lwt, Async, and Domainslib.</p>
<h3 style="position:relative;"><a href="https://tarides.com/feed.xml#eio-and-lwt" aria-label="eio and lwt permalink" class="anchor before"><svg aria-hidden="true" focusable="false" height="16" version="1.1" viewbox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Eio and Lwt</h3>
<p>When comparing Lwt and Eio there are a few things to consider. First of all, Eio's use of direct-style is shorter and easier for beginners to use. Secondly, and perhaps more significant to the average user, Eio is faster. This holds true even when just one core is being used. For a more detailed breakdown of times, check out the <a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/blob/main/doc/intro.md">Eio Introduction and Lwt Comparison</a> part of the tutorial.</p>
<p>Eio also manages error handling and backtraces differently; for example, Eio reports exceptions immediately in cases where two tasks are running concurrently, and backtraces are also more specific. Furthermore, Eio prevents the type of resource leaks that Lwt often allows to happen by requiring all resources to be tied to a switch, ensuring that they are released when the switch finishes.</p>
<p>Finally, Eio makes it clearer to understand how the program relates to the outside world since it does so through a function argument usually named <code>env</code>. By looking at what happens to <code>env</code>, the user gets a bound on the program's behaviour. Lwt does not do this, typically just starting by saying it will run <code>main</code> with no further context.</p>
<h2 style="position:relative;"><a href="https://tarides.com/feed.xml#tutorial-overview" aria-label="tutorial overview permalink" class="anchor before"><svg aria-hidden="true" focusable="false" height="16" version="1.1" viewbox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a><a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/tree/main">Tutorial</a> Overview:</h2>
<p>The tutorial covers the following topics:</p>
<ul>
<li><strong><a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/blob/main/doc/prereqs.md">Prerequisites:</a></strong> Walks you through what to install before starting the tutorial, including optional Docker and ThreadSanitizer files, as well as tips and common pitfalls.</li>
<li><strong><a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/blob/main/doc/intro.md">Eio Introduction and Lwt Comparison:</a></strong> Outlines the main differences between Eio and Lwt, including performance, error handling, and bounds on behaviour.</li>
<li><strong><a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/blob/main/doc/porting.md">Porting From Lwt to Eio:</a></strong> The core of the tutorial, this section walks you through how to take an example application in Lwt and port it to Eio. It gives you an overview of the code, tells you how to convert the code, and how to take advantage of Eio features.</li>
<li><strong><a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/blob/main/doc/multicore.md">Using Multiple Cores:</a></strong> Instructions on how to use multiple cores to improve performance. The section includes topics like thread-safe logging, using multiple domains with <code>cohttp</code>, testing, and suggestions on useful tools.</li>
</ul>
<h2 style="position:relative;"><a href="https://tarides.com/feed.xml#feedback" aria-label="feedback permalink" class="anchor before"><svg aria-hidden="true" focusable="false" height="16" version="1.1" viewbox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>Feedback</h2>
<p>It really helps the teams to receive feedback and constructive comments on how to improve documentation for users. We encourage you to share your thoughts on the <a href="https://github.com/ocaml-multicore/icfp-2023-eio-tutorial/tree/main">repo</a>, or on the <a href="https://discuss.ocaml.org">OCaml Discuss</a> forum.</p>
<p>You can also <a href="https://tarides.com/contact/">contact us</a> on our website with any questions or concerns.</p>