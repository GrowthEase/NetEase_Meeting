class NEMeetingKit {
  static instance;

  _config;
  _language;

  instance(config) {
    this._config = config;
  }

  static getInstance() {
    if (!this.instance) {
      this.instance = new NEMeetingKit();
    }
    return this.instance;
  }
}

module.exports = NEMeetingKit;
