$(document).ready(function() {
  $(".delete").click(function() {
    var $row = jQuery(this).closest("tr");
    var server_key = $row.data("server-key");
    var route_index = $row.data("route-index");
    delete_route(server_key, route_index);
  });
});

function delete_route(server_key, route_index){
  var server_url = $('#caddy-server-url').text();
  $.ajax({
    url: (window.location.origin + '/api/delete/' + server_key + '/' + route_index),
    type: 'DELETE',
    success: function(result) {
      console.log(result);
      location.reload();
    }
  });
};

// http://10.0.0.110:2019/config/apps/http/servers/srv1/routes/0