---
layout: default
title: Posts
---
<div class="row">
{% for post in site.posts %}
  <div class="card mb-4 w-100">
    <div class="card-body">
      <h2 class="card-title">{{ post.title }}</h2>
      <p class="card-text">{{ post.excerpt }}</p>
      <a href="{{ post.url | absolute_url }}" class="btn btn-primary">Read More &rarr;</a>
    </div>
    <div class="card-footer text-muted">
      Posted on {{ post.date | date_to_string }}
      {% assign author = site.authors | where: 'short_name', post.author | first %}
      {% if author %}
       by <a href="{{ author.url | absolute_url }}">{{ author.name }}</a>
      {% endif %}
    </div>
  </div>
{% endfor %}
</div>