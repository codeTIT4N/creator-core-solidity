// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "manifoldxyz-libraries-solidity/contracts/access/AdminControl.sol";
import "./core/ERC721CreatorCore.sol";

contract ERC721Creator is AdminControl, ERC721, ERC721CreatorCore {

    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol) {
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721CreatorCore, AdminControl) returns (bool) {
        return ERC721CreatorCore.supportsInterface(interfaceId) || ERC721.supportsInterface(interfaceId) || AdminControl.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721CreatorCore-registerExtension}.
     */
    function registerExtension(address extension, string calldata baseURI) external override adminRequired nonBlacklistRequired(extension) {
        _registerExtension(extension, baseURI, false);
    }

    /**
     * @dev See {IERC721CreatorCore-registerExtension}.
     */
    function registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) external override adminRequired nonBlacklistRequired(extension) {
        _registerExtension(extension, baseURI, baseURIIdentical);
    }


    /**
     * @dev See {IERC721CreatorCore-unregisterExtension}.
     */
    function unregisterExtension(address extension) external override adminRequired {
        _unregisterExtension(extension);
    }

    /**
     * @dev See {IERC721CreatorCore-blacklistExtension}.
     */
    function blacklistExtension(address extension) external override adminRequired {
        _blacklistExtension(extension);
    }

    /**
     * @dev See {IERC721CreatorCore-setBaseTokenURIExtension}.
     */
    function setBaseTokenURIExtension(string calldata uri) external override extensionRequired {
        _setBaseTokenURIExtension(uri, false);
    }

    /**
     * @dev See {IERC721CreatorCore-setBaseTokenURIExtension}.
     */
    function setBaseTokenURIExtension(string calldata uri, bool identical) external override extensionRequired {
        _setBaseTokenURIExtension(uri, identical);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURIPrefixExtension}.
     */
    function setTokenURIPrefixExtension(string calldata prefix) external override extensionRequired {
        _setTokenURIPrefixExtension(prefix);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURIExtension}.
     */
    function setTokenURIExtension(uint256 tokenId, string calldata uri) external override extensionRequired {
        _setTokenURIExtension(tokenId, uri);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURIExtension}.
     */
    function setTokenURIExtension(uint256[] memory tokenIds, string[] calldata uris) external override extensionRequired {
        require(tokenIds.length == uris.length, "ERC721Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            _setTokenURIExtension(tokenIds[i], uris[i]);            
        }
    }

    /**
     * @dev See {IERC721CreatorCore-setBaseTokenURI}.
     */
    function setBaseTokenURI(string calldata uri) external override adminRequired {
        _setBaseTokenURI(uri);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURIPrefix}.
     */
    function setTokenURIPrefix(string calldata prefix) external override adminRequired {
        _setTokenURIPrefix(prefix);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURI}.
     */
    function setTokenURI(uint256 tokenId, string calldata uri) external override adminRequired {
        _setTokenURI(tokenId, uri);
    }

    /**
     * @dev See {IERC721CreatorCore-setTokenURI}.
     */
    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external override adminRequired {
        require(tokenIds.length == uris.length, "ERC721Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            _setTokenURI(tokenIds[i], uris[i]);            
        }
    }

    /**
     * @dev See {IERC721CreatorCore-setMintPermissions}.
     */
    function setMintPermissions(address extension, address permissions) external override adminRequired {
        _setMintPermissions(extension, permissions);
    }

    /**
     * @dev See {IERC721CreatorCore-mintBase}.
     */
    function mintBase(address to) public override nonReentrant adminRequired virtual returns(uint256) {
        return _mintBase(to, "");
    }

    /**
     * @dev See {IERC721CreatorCore-mintBase}.
     */
    function mintBase(address to, string calldata uri) public override nonReentrant adminRequired virtual returns(uint256) {
        return _mintBase(to, uri);
    }

    /**
     * @dev See {IERC721CreatorCore-mintBaseBatch}.
     */
    function mintBaseBatch(address to, uint16 count) public override nonReentrant adminRequired virtual returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](count);
        for (uint16 i = 0; i < count; i++) {
            tokenIds[i] = _mintBase(to, "");
        }
        return tokenIds;
    }

    /**
     * @dev See {IERC721CreatorCore-mintBaseBatch}.
     */
    function mintBaseBatch(address to, string[] calldata uris) public override nonReentrant adminRequired virtual returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](uris.length);
        for (uint i = 0; i < uris.length; i++) {
            tokenIds[i] = _mintBase(to, uris[i]);
        }
        return tokenIds;
    }

    /**
     * @dev Mint token with no extension
     */
    function _mintBase(address to, string memory uri) internal virtual returns(uint256 tokenId) {
        _tokenCount++;
        tokenId = _tokenCount;

        // Track the extension that minted the token
        _tokensExtension[tokenId] = address(this);

        _safeMint(to, tokenId);

        if (bytes(uri).length > 0) {
            _tokenURIs[tokenId] = uri;
        }

        // Call post mint
        _postMintBase(to, tokenId);
        return tokenId;
    }


    /**
     * @dev See {IERC721CreatorCore-mintExtension}.
     */
    function mintExtension(address to) public override nonReentrant extensionRequired virtual returns(uint256) {
        return _mintExtension(to, "");
    }

    /**
     * @dev See {IERC721CreatorCore-mintExtension}.
     */
    function mintExtension(address to, string calldata uri) public override nonReentrant extensionRequired virtual returns(uint256) {
        return _mintExtension(to, uri);
    }

    /**
     * @dev See {IERC721CreatorCore-mintExtensionBatch}.
     */
    function mintExtensionBatch(address to, uint16 count) public override nonReentrant extensionRequired virtual returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](count);
        for (uint16 i = 0; i < count; i++) {
            tokenIds[i] = _mintExtension(to, "");
        }
        return tokenIds;
    }

    /**
     * @dev See {IERC721CreatorCore-mintExtensionBatch}.
     */
    function mintExtensionBatch(address to, string[] calldata uris) public override nonReentrant extensionRequired virtual returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](uris.length);
        for (uint i = 0; i < uris.length; i++) {
            tokenIds[i] = _mintExtension(to, uris[i]);
        }
    }
    
    /**
     * @dev Mint token via extension
     */
    function _mintExtension(address to, string memory uri) internal virtual returns(uint256 tokenId) {
        _tokenCount++;
        tokenId = _tokenCount;

        _checkMintPermissions(msg.sender, to, tokenId);

        // Track the extension that minted the token
        _tokensExtension[tokenId] = msg.sender;

        _safeMint(to, tokenId);

        if (bytes(uri).length > 0) {
            _tokenURIs[tokenId] = uri;
        }
        
        // Call post mint
        _postMintExtension(to, tokenId);
        return tokenId;
    }

    /**
     * @dev See {IERC721CreatorCore-tokenExtension}.
     */
    function tokenExtension(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "Nonexistent token");
        return _tokenExtension(tokenId);
    }

    /**
     * @dev See {IERC721CreatorCore-burn}.
     */
    function burn(uint256 tokenId) public override nonReentrant virtual {
        _preBurn(ownerOf(tokenId), tokenId);
        _burn(tokenId);
    }

    /**
     * @dev See {IERC721CreatorCore-setRoyalties}.
     */
    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(address(this), receivers, basisPoints);
    }

    /**
     * @dev See {IERC721CreatorCore-setRoyalties}.
     */
    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        require(_exists(tokenId), "Nonexistent token");
        _setRoyalties(tokenId, receivers, basisPoints);
    }

    /**
     * @dev See {IERC721CreatorCore-setRoyaltiesExtension}.
     */
    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(extension, receivers, basisPoints);
    }

    /**
     * @dev {See IERC721CreatorCore-getRoyalties}.
     */
    function getRoyalties(uint256 tokenId) external view virtual override returns (address payable[] memory, uint256[] memory) {
        require(_exists(tokenId), "Nonexistent token");
        return (_getRoyaltyReceivers(tokenId), _getRoyaltyBasisPoints(tokenId));
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _tokenURI(tokenId);
    }
    
}