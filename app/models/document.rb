class Document < ApplicationRecord
  has_paper_trail
  has_many_attached :embeds  # 1対多(複数枚画像投稿)で関連付けるという宣言
  # Active Storageを使って、embedsという名前で1対多の関係（複数の画像投稿）を持つことを宣言
  # embedsって何？どこか別のところで定義されてるの？
  # embedsは、このコード内では明示的に定義されていませんが、has_many_attached :embedsという宣言（has_manyではなくhas_many_attachedであることが大事）
  # によって、embedsという名前で、DocumentモデルとActive Storageで管理されるファイル（画像など）との間に1対多の関係が作られています。
  # つまり、TODO:（ここから重要⇒）embedsは、このDocumentモデルに添付された複数のファイル（例えば、画像）を表しています。
  
  # Active Storageで管理されるファイル（画像など）との間に1対多の関係が作られているのであれば、
  # どこかにbelongs_to: documentのような記載がされている箇所が別ファイルであるということ？
  # 実際には、belongs_to :documentのような記述は別ファイルに存在しません。
  # RailsのActive Storageは、has_many_attachedやhas_one_attachedメソッドを使って、
  # モデルとファイル（画像など）との間に関連付けを行いますが、
  # この関連付けは通常のhas_manyやbelongs_toとは異なる方法で実現されています。
  # Active Storageは、2つのテーブル（active_storage_blobsとactive_storage_attachments）を使用して、
  # ファイルのメタデータとそのファイルが関連付けられたモデル間の関連を管理します。
  # active_storage_blobsテーブルにはファイルのメタデータが、
  # active_storage_attachmentsテーブルには関連付け情報が格納されます。
  # たとえば、has_many_attached :embedsを使用すると、Active Storageはactive_storage_attachmentsテーブルに、
  # TODO: （ここから重要⇒）record_type（ここではDocument）、record_id（モデルのID）、name（ここではembeds）、
  # およびblob_id（関連するactive_storage_blobsテーブルのID）といった情報を持つレコードを作成します。
  # これにより、embedsという名前で、Documentモデルとファイルの間に1対多の関係が作られます。
  # has_many_attachedやhas_one_attachedを使用すると、Active Storageは自動的にこの関連付けを処理し、
  # 関連するモデルでファイルにアクセスできるようになります。
  # そのため、belongs_to :documentのような記述は必要ありません。

  before_save :set_embeds
  # 保存（save）する前に、set_embedsメソッドを実行するように設定しています。

  private

  def set_embeds
    return if content.blank?

    nokogiri_html = Nokogiri::HTML.parse(content)
    # Nokogiri は、Rubyで使用されるXMLおよびHTMLパーサーライブラリーで、XMLまたはHTMLドキュメントを解析および操作するために使用されます。
    # nokogiri_html は、Nokogiri::HTML.parse メソッドを使用して、Document モデルの content カラムに格納されたHTML文字列をパースして得られた Nokogiri オブジェクトを格納します。
    # つまり、この行は、content カラムに格納されたHTML文字列を解析して、nokogiri_html 変数に Nokogiri オブジェクトとして格納するために使われます。
    # Nokogiri オブジェクトを使用することで、HTML文書を走査したり、要素を操作したりすることができます。

    # parseという言葉自体は解析するという意味
    # parseメソッド は、文字列からXMLまたはHTML文書を解析して、解析済みの文書を表すオブジェクトを生成するメソッドです。
    # 具体的には、Nokogiri ライブラリーに含まれるメソッドの1つであり、HTMLまたはXML文書の構造を解析し、木構造の階層を形成するために使用されます。
    # たとえば、Nokogiri::HTML.parse(content) は、HTML形式の content 文字列を解析して、 Nokogiri オブジェクトを生成します。
    # このオブジェクトには、HTMLドキュメントの要素、属性、テキストノードなどが含まれます。
    # 生成された Nokogiri オブジェクトは、XMLまたはHTML文書の解析と操作に使用されます。
    # parse メソッドは、Nokogiri ライブラリーだけでなく、Rubyの標準ライブラリーにも含まれています。
    # たとえば、JSON形式の文字列を解析するためには、JSON.parse メソッドを使用します。
    # parse メソッドは、文字列から構造化されたデータを生成するための一般的な手段として使用されます。
    sgids = nokogiri_html.css('figure').map do |figure|
      # nokogiri_htmlオブジェクトからfigureタグを持つ要素を取得し、それらを走査してsgids配列に結果を格納。
      trix_attachment = JSON.parse(figure['data-trix-attachment'])
      trix_attachment['sgid']
    end
    blobs = sgids.map { |sgid| ActiveStorage::Blob.find_signed(sgid) }
    # ActiveStorage::Blobオブジェクトは、RailsのActive Storageでファイル（画像、動画、ドキュメントなど）のメタデータを表すオブジェクトです。
    # Active Storageは、アプリケーションのモデルとファイルを関連付けるためのフレームワークであり、さまざまなストレージサービス（ローカルディスク、Amazon S3、Google Cloud Storageなど）にファイルを保存できます。
    # ActiveStorage::Blobオブジェクトには、ファイル名、コンテンツタイプ（MIMEタイプ）、ファイルサイズ、チェックサムなどのメタデータが格納されており、それを使ってファイルにアクセスしたり、ダウンロードしたり、表示したりすることができます。
    
    self.embeds = blobs - embeds.map(&:blob)
    # 現在のembedsに紐づくblobと、取得したblobsの差分を、self.embedsに設定しています。
  end
end


