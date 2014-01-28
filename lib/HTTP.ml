(*
 * Copyright (c) 2012-2014 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2013 Thomas Gazagnaire <thomas@gazazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

open Lwt

module Make(Channel:V1_LWT.CHANNEL) = struct

  module HTTP_IO = HTTP_IO.Make(Channel)

  module Net_IO = struct

    module IO = HTTP_IO

    let connect_uri uri =
      fail (Failure "not implemented")

    let connect ?ssl ~host ~service () =
      fail (Failure "not implemented")

    let close_in ic = ()
    let close_out ic = ()
    let close ic oc = ignore_result (Channel.close ic)

  end

  (* Build all the core modules from the [Cohttp_lwt] functors *)
  module Request = Cohttp_lwt.Make_request(HTTP_IO)
  module Response = Cohttp_lwt.Make_response(HTTP_IO)
  module Client = Cohttp_lwt.Make_client(HTTP_IO)(Request)(Response)(Net_IO)
  module Server_core = Cohttp_lwt.Make_server(HTTP_IO)(Request)(Response)(Net_IO)

  (* Extend the [Server_core] module with the Mirage-specific
     listen function. *)
  module Server = struct
    include Server_core

    let listen spec flow =
      let ch = Channel.create flow in
      Server_core.callback spec ch ch 

  end
end
