(import freja/default-hotkeys :as dh)
(import spork/netrepl)
(import spork/msg)
(import freja/new_gap_buffer :as gb)

(def server-code
  ['(import spork/netrepl)
   '(netrepl/server)])

(when-let [{:ref r} (dyn 'process)]
  (print "killing process")
  (os/proc-kill (r 0)))

(def process (os/spawn ["janet" "-e" (string/join (map |(string/format "%p" $) server-code) "\n")] :p))

(def stack @[])


(defmacro- nilerr
  "Coerce errors to nil."
  [& body]
  (apply try ~(do ,;body) [~([_] nil)]))

(defn make-recv
  "Get a function that, when invoked, gets the next message from a readable stream.
  Provide an optional unpack function that will parse the received buffer."
  [stream &opt unpack]
  (def buf @"")
  (default unpack string)
  (fn receiver []
    (buffer/clear buf)
    (if-not (nilerr (ev/read stream 4 buf)) (break))
    (def [b0 b1 b2 b3] buf)
    (def len (+ b0 (* b1 0x100) (* b2 0x10000) (* b3 0x1000000)))
    (buffer/clear buf)
    (if-not (nilerr (ev/read stream len buf)) (break))
    (unpack (string buf))))

(defn client
  "Connect to a repl server. The default host is \"127.0.0.1\" and the default port
  is \"9365\"."
  [&opt host port name]
  (default host netrepl/default-host)
  (default port netrepl/default-port)
  (default name (string "[" host ":" port "]"))
  (def stream (net/connect host port))
  (def recv (make-recv stream))
  (def send (msg/make-send stream))
  (send name)
  {:stream stream
   :recv recv
   :send send})

(def c (client))


(ev/spawn
  (forever
    (prin ((c :recv)))))

(comment
  (ev/spawn
    (forever
      (print "ev thing " ((c :recv)))))
  (ev/spawn (print "ev send " ((c :send) "(* 5 5)")))

  #
)

(defn netrepl-eval
  [s]
  ((c :send) s))

(defn netrepl-load-file
  [{:path path}]
  # code to send function call to netrepl
  (netrepl-eval (string/format `(dofile "%s")` path)))

(defn netrepl-eval-buffer
  [gb]
  # code to send function call to netrepl
  (let [content (gb/content gb)]
    (prin content)
    (netrepl-eval content)))

(dh/set-key dh/gb-binds [:alt :l] netrepl-load-file)
(dh/set-key dh/gb-binds [:alt :b] netrepl-eval-buffer)
