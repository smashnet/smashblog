# smashblog
## Description


This project is a smashblog implementation. It provides a simple blog system with
Markdown content and a Jekyll-based setup.

## Features

- Markdown-based blog posts
- Jekyll static site generator
- Responsive design
- Customizable themes
- Social media integration

## Installation

### Prerequisites

- Ruby (>= 2.3)
- Jekyll (>= 3.5)
- Bundler

### Steps

1. Install Ruby and Jekyll:
   ```sh
   gem install jekyll bundler
   ```

2. Clone the repository:
   ```sh
   git clone https://github.com/user/smashblog.git
   cd smashblog
   ```

3. Install dependencies:
   ```sh
   bundle install
   ```

## Usage

### Running locally

To run the site locally:
```sh
bundle exec jekyll serve
```

### Building the site

To build the site for production:
```sh
bundle exec jekyll build
```

## Deployment

### Deploy to GitHub Pages

1. Configure your GitHub repository with GitHub Pages.
2. Update configuration in `_config.yml`:
   ```yaml
   baseurl: '/smashblog'
   url: 'https://user.github.io'
   ```
3. Push the `master` branch to your repository.

## Contributing

Please read [contributing.md](contributing.md) for details on the
process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details.

## Credit

- This project was created by [Nicolas Inden](https://inden.one)
