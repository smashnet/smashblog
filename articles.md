---
layout: default
title: Articles
---
<div class="row">
  <div class="col-sm-12">
  {% for post in site.posts %}
    {% if post.category == "article" %}
      {% include post_preview.html %}
    {% endif %}
  {% endfor %}
  </div>
</div>
